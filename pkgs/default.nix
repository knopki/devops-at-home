{
  self,
  pkgs,
  nixpkgsUnstable ? pkgs,
  nixpkgs-24-11 ? pkgs,
  ...
}:
let
  mkNixPakPackage =
    args:
    let
      mkNixPak = self.inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
      };
      pkg = mkNixPak args;
    in
    pkg.config.env // { inherit (pkg.config.app.package) meta; };

  extLib = pkgs.lib.extend (
    _: prev: {
      extended = import ../lib { lib = prev; };
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
