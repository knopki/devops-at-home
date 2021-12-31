{ config, lib, pkgs, nixDoomFlake, inputs, ... }:
with lib;
let
  emacsPackagesOverlay = final: prev: rec {
    straightBuild = { pname, ... }@args: prev.trivialBuild ({
      ename = pname;
      version = "1";
      src = if args ? "src" then src else inputs.nix-doom-emacs.inputs.${pname};
      buildPhase = ":";
    } // args);

    #org-mode = straightBuild rec {
    #  pname = "org-mode";
    #  version = "9.5";
    #  src = inputs.org-mode;
    #  installPhase = ''
    #    LISPDIR=$out/share/emacs/site-lisp
    #    install -d $LISPDIR
    #    cp -r * $LISPDIR
    #    cat > $LISPDIR/lisp/org-version.el <<EOF
    #    (fset 'org-release (lambda () "${version}"))
    #    (fset 'org-git-version #'ignore)
    #    (provide 'org-version)
    #    EOF
    #  '';
    #};
    #org-with-contrib = org-mode;
    #org = org-mode;
  };
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
