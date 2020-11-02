{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-20.03";
    };

    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
    };

    # Provides a basic system for managing a user environment
    # using the Nix package manager together with the Nix
    # libraries found in Nixpkgs: https://github.com/nix-community/home-manager
    home = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-20.09";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doom-emacs = {
      type = "github";
      owner = "hlissner";
      repo = "doom-emacs";
      flake = false;
    };

    nix-doom-emacs = {
      type = "github";
      owner = "vlaci";
      repo = "nix-doom-emacs";
      flake = false;
    };
  };

  outputs = inputs@{ self, home, nixpkgs, nixpkgs-unstable, nixos-hardware, ... }:
    let
      inherit (builtins) attrNames attrValues baseNameOf elem filter listToAttrs readDir;
      inherit (nixpkgs.lib) genAttrs filterAttrs hasSuffix removeSuffix;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: genAttrs systems (system: f system);
      prepModules = map (
        path: {
          name = removeSuffix ".nix" (baseNameOf path);
          value = import path;
        }
      );

      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = forAllSystems (
        system:
          import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
            overlays = attrValues self.overlays;
          }
      );

      outerOverlays = { };
    in
      {
        nixosConfigurations = let
          configs = import ./hosts (inputs // { inherit nixpkgsFor; });
        in
          configs;

        overlay = import ./pkgs;

        overlays = let
          filenames = filter (hasSuffix ".nix") (attrNames (readDir ./overlays));
          names = map (removeSuffix ".nix") filenames;
          overlays = genAttrs names (name: import (./overlays + "/${name}.nix"));
        in
          outerOverlays // overlays;

        packages = forAllSystems (
          system: filterAttrs (n: v: elem system v.meta.platforms) {
            inherit (nixpkgsFor.${system}) sway-scripts winbox winbox-bin;
          }
        );

        nixosModules = let
          # binary cache
          cachix = import ./cachix.nix;
          cachixAttrs = { inherit cachix; };

          # modules
          moduleList = import ./modules/list.nix;
          modulesAttrs = listToAttrs (prepModules moduleList);
          hmModuleList = import ./hm-modules/list.nix;
          hmModulesAttrs = { home-manager = listToAttrs (prepModules hmModuleList); };

          # profiles
          profileList = import ./profiles/list.nix;
          profilesAttrs = { profiles = listToAttrs (prepModules profileList); };
        in
          cachixAttrs // modulesAttrs // hmModulesAttrs // profilesAttrs;

        checks.x86_64-linux = self.packages.x86_64-linux // {
          alien = self.nixosConfigurations.alien.config.system.build.toplevel;
          # iso = self.nixosConfigurations.iso.config.system.build.isoImage;
        };

        devShell = forAllSystems (
          system: import ./shell.nix { pkgs = nixpkgsFor.${system}; }
        );
      };
}
