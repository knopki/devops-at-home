{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home.url = "github:nix-community/home-manager/release-20.09";
    home.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
    base16-default-schemes.flake = false;
    base16-default-schemes.url = "github:chriskempson/base16-default-schemes";
    base16-dracula-scheme.flake = false;
    base16-dracula-scheme.url = "github:dracula/base16-dracula-scheme";
    base16-textmate.flake = false;
    base16-textmate.url = "github:chriskempson/base16-textmate";
    dracula-zathura.flake = false;
    dracula-zathura.url = "github:dracula/zathura";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
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
