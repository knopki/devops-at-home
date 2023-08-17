{
  config,
  lib,
  pkgs,
  nixDoomFlake,
  inputs,
  ...
}:
with lib; let
  emacsPackagesOverlay = final: prev: rec {
    straightBuild = {pname, ...} @ args:
      prev.trivialBuild ({
          ename = pname;
          version = "1";
          src =
            if args ? "src"
            then src
            else inputs.nix-doom-emacs.inputs.${pname};
          buildPhase = ":";
        }
        // args);

    evil-collection = pkgs.emacsPackages.evil-collection;

    lark-mode = prev.melpaBuild rec {
      pname = "lark-mode";
      ename = pname;
      version = "20230327.1003";
      src = pkgs.fetchFromGitHub {
        owner = "taquangtrung";
        repo = "lark-mode";
        rev = "9e19b40df29d273cf3aec9ddd0e739d3b3d9b3a8";
        sha256 = "1q0hfln8xa78q2r4zw0vm66by8nr9n7pvrn096ys5ggi5835cgah";
      };
      commit = "93b5cdb6a14ada9ca5ea967c77b1ae23472c4171";
      sha256 = "0dn1i8cvbrzkfsg6hz1xkwzg9mm2vvij9sa5c2swbfb3fb9bc7as";
      recipe = pkgs.fetchurl {
        name = pname + "-recipe";
        url = "https://raw.githubusercontent.com/melpa/melpa/${commit}/recipes/${ename}";
        inherit sha256;
      };
    };
  };
in {
  inherit emacsPackagesOverlay;
}
