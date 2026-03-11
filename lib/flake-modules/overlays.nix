# flake.parts' flakeModule
#
# Load overlays from /overlays
#
{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib.attrsets)
    attrValues
    mapAttrs
    ;

  extPackagesOverlay = final: _prev: {
    nixpkgsUnstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config = self.lib.nixpkgsPolicies.configStandard;
    };
    llmAgents = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system};
    devenvUpstream = inputs.devenv.packages.${final.stdenv.hostPlatform.system};
  };

  namePaths = import ../../overlays/overlays.nix;
  loadOverlay = _: import;
  namedOverlays = mapAttrs loadOverlay namePaths;

  myPackagesOverlay =
    _final: prev:
    let
      inherit (prev.stdenv.hostPlatform) system;
      inherit (config.allSystems.${system}) packages;
    in
    if (elem system config.systems) then packages else { };
in
{
  config = {
    _module.args.packageOverlaysForPkgs = [
      extPackagesOverlay
    ]
    ++ attrValues namedOverlays;

    flake = {
      overlays = namedOverlays // {
        extPackages = extPackagesOverlay;
        # all packages of this flake
        myPackages = myPackagesOverlay;
        default = myPackagesOverlay;
      };
    };
  };
}
