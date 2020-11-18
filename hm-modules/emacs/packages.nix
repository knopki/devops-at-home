{ config, lib, pkgs, nixDoomFlake, ... }:
with lib;
let
  pinnedPackages = builtins.fromJSON (readFile ./pinned.json);
  pinnedPackagesAttr = foldr (a: b: b // { "${a.name}" = a; }) { } pinnedPackages;
  pkgAliases = [
    { pname = "evil-org-mode"; ename = "evil-org"; }
  ];

  mkPkgSrc = pkg: ({ src = null; } // (optionalAttrs (pkg.fetcher == "git") {
    src = fetchgit {
      inherit (pkg) sha256;
      url = pkg.repo;
    };
  }) // (optionalAttrs (pkg.fetcher == "github") {
    src = pkgs.fetchFromGitHub {
      inherit (pkg) sha256 rev;
      owner = last (init (splitString "/" pkg.repo));
      repo = last (splitString "/" pkg.repo);
    };
  }) // (optionalAttrs (pkg.fetcher == "gitlab") {
    src = pkgs.fetchFromGitLab {
      inherit (pkg) sha256 rev;
      owner = last (init (splitString "/" pkg.repo));
      repo = last (splitString "/" pkg.repo);
    };
  })).src;

  sourcesWOAliases = foldr (a: b: b // { "${a.name}" = mkPkgSrc a; }) { } pinnedPackages;
  sources = foldr
    (a: b: b // { "${a.pname}" = b."${a.ename}"; })
    sourcesWOAliases
    pkgAliases;

  emacsPackagesOverlay = final: prev:
    let
      doomMelpaEmacsOverlay = foldr
        (a: b: b // {
          "${a.name}" = prev."${a.name}".overrideAttrs (o: {
            src = sources."${a.name}";
          });
        })
        { }
        (filter (x: x.origin == "melpa") pinnedPackages);

      nixDoomEmacsOverrides = pkgs.callPackage
        "${nixDoomFlake.outPath}/overrides.nix"
        { lock = name: sources."${name}"; }
        final
        prev;

      straightBuild = nixDoomEmacsOverrides.straightBuild;

      otherPkgs = filter
        (x: !(elem x.name (attrNames (doomMelpaEmacsOverlay // nixDoomEmacsOverrides))))
        pinnedPackages;
      othersOverlay = foldr
        (a: b: a // {
          "${a.name}" = straightBuild {
            pname = a.name;
          };
        })
        { }
        otherPkgs;

      fixes = rec {
        cmake-mode = straightBuild { pname = "cmake-mode"; };
        org-mode = prev.melpaBuild rec {
          pname = "org-mode";
          version = "9.5";
          src = sources."${pname}";
          recipe = pkgs.writeText "recipe" ''
            (${pname} :fetcher github :repo "emacs-straight/org-mode"
            :files ("*.el" "lisp/*.el" "contrib/lisp/*.el" "etc"))
          '';
          preBuild = ''
            cat > org-version.el <<EOF
            (fset 'org-release (lambda () "${version}"))
            (fset 'org-git-version #'ignore)
            (provide 'org-version)
            EOF
          '';
        };
        org-with-contrib = org-mode;
        org = org-mode;
      };

      overlays = doomMelpaEmacsOverlay // nixDoomEmacsOverrides // othersOverlay // fixes;
    in
    overlays;
in
{
  inherit emacsPackagesOverlay;
  doom-org-capture = pkgs.callPackage
    (
      { stdenv, lib, makeWrapper, pkgs, ... }:
      stdenv.mkDerivation rec {
        name = "doom-org-capture";
        src = nixDoomFlake.inputs.doom-emacs;
        nativeBuildInputs = [ makeWrapper ];
        installPhase = ''
          install -Dm0755 $src/bin/org-capture $out/bin/$name
          wrapProgram $out/bin/$name \
            --set PATH "${config.programs.emacs.package}/bin:${pkgs.coreutils}/bin"
        '';
      }
    )
    { };
  orgProtoClientDesktopItem = pkgs.writeTextDir "share/applications/org-protocol.desktop"
    (
      generators.toINI { } {
        "Desktop Entry" = {
          Type = "Application";
          Exec = "${config.programs.emacs.package}/bin/emacsclient -c %u";
          Terminal = false;
          Name = "Org Protocol";
          Icon = "emacs";
          MimeType = "x-scheme-handler/org-protocol;";
          Categories = "Utility;TextEditor;";
          StartupWMClass = "Emacs";
        };
      }
    );
}
