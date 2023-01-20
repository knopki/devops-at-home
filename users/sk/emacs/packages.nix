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
}
