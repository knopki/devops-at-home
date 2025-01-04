{
  self,
  pkgs,
  nixpkgsUnstable,
  nixpkgs-24-11,
  inputs,
  ...
}:
let
  mkNixPakPackage =
    args:
    let
      mkNixPak = inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
      };
      pkg = mkNixPak args;
    in
    pkg.config.env // { inherit (pkg.config.app.package) meta; };

  extLib = pkgs.lib.extend (
    _: prev: {
      extended = import ../lib {
        inherit (inputs) haumea;
        lib = prev;
      };
    }
  );
  extPkgs = pkgs.extend (
    _: _: {
      inherit
        self
        nixpkgsUnstable
        nixpkgs-24-11
        extLib
        mkNixPakPackage
        ;
    }
  );
  pkgsByName = extLib.extended.filesystem.toPackages extPkgs ./.;
in
pkgsByName
# // {
#   vscode-insiders-with-extensions = extPkgs.vscode-with-extensions.override {
#     vscode = pkgsByName.vscode-insiders;
#   };
# }
