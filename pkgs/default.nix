{
  self,
  pkgs,
  nixpkgsUnstable,
  nixpkgs-24-11,
  inputs,
  ...
}:
let
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
