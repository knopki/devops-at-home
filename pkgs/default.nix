{
  lib,
  pkgs,
  nixpkgsUnstable,
}: let
  inherit (lib) callPackageWith;
  sources = callPackage ./_sources/generated.nix {};
  callInputs = pkgs // {inherit sources;};
  callPackage = callPackageWith callInputs;
in rec {
  framesh = callPackage ./framesh.nix {};
  ledger-live-desktop = callPackage ./ledger-live-desktop.nix {};
  marvin = callPackage ./marvin.nix {};
  pass = pkgs.pass.override {
    waylandSupport = pkgs.stdenv.hostPlatform.isLinux;
  };
}
