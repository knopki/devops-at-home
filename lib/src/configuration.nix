{ lib, super, ... }:
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
    rec {
      inherit inputs self;
      inherit inputs' self';
      inherit packages;
    };

  /**
    Creates NixOS configuration.
    Example: see nixos/flake-module.nix.
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
        extraSpecialArgs = {
          # TODO: remove after >= 24.11
          osConfig = null;
        } // mkSpecialArgs (perSystemArgs // topArgs);
      }
    );
}
