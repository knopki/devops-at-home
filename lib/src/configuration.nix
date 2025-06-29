{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
in
rec {
  /**
    Creates common module import arguments for nixos and home configuration.
    Should be called with attrset with all required dependencies.
  */
  mkSpecialArgs =
    {
      config,
      inputs,
      inputs',
      self,
      self',
      packages ? args.config.packages,
      ...
    }@args:
    {
      inherit inputs self;
      inherit inputs' self';
      inherit packages;
    };

  /**
    Creates NixOS configuration.
  */
  nixosConfigurationLoader =
    {
      # from flake.parts
      withSystem,
      # specialArgs dependencies
      inputs,
      self,
      ...
    }@topArgs:
    {
      # set machine's arch
      system,
      # provide nixosSystem from your nixpkgs
      nixosSystem,
      # modules to import
      modules,
      ...
    }:
    withSystem system (
      perSystemArgs:
      nixosSystem {
        inherit modules system;
        specialArgs = mkSpecialArgs (perSystemArgs // topArgs);
      }
    );

  /**
    Convert attrset of paths to attrset NixOS configurations.
  */
  mkNixosConfigurationsAttrset =
    {
      inputs,
      self,
      withSystem,
      configurations,
      ...
    }:
    let
      deps = { inherit inputs self withSystem; };
      fullDeps = deps // {
        mkNixosConfiguration = nixosConfigurationLoader deps;
      };
    in
    mapAttrs (_: path: import path fullDeps) configurations;

  /**
    Creates home configuration.
    Example: see home/flake-module.nix.
  */
  homeConfigurationLoader =
    {
      # from flake.parts
      withSystem,
      # specialArgs dependencies
      inputs,
      self,
      ...
    }@topArgs:
    {
      # set architecture
      system,
      # provide function from your home-manager
      homeManagerConfiguration,
      # bring your own packages
      pkgs,
      # modules to include
      modules,
      ...
    }:
    topArgs.withSystem system (
      perSystemArgs:
      homeManagerConfiguration {
        inherit modules pkgs;
        extraSpecialArgs = mkSpecialArgs (perSystemArgs // topArgs);
      }
    );
}
