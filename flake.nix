{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  nixConfig = {
    commit-lockfile-summary = "flake: bump inputs";
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
    ];
  };

  inputs = {
    # nixpkgs
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-25-05.url = "nixpkgs/nixos-25.05";
    nixpkgs-25-11.url = "nixpkgs/nixos-25.11";
    nixpkgs.follows = "nixpkgs-25-11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # core modules and libraries
    flake-parts.url = "flake:flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "flake:flake-utils";
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    home-25-05.inputs.nixpkgs.follows = "nixpkgs-25-05";
    home-25-05.url = "github:nix-community/home-manager/release-25.05";
    home.follows = "home-25-05";
    preservation.url = "github:nix-community/preservation";
    sops-nix.url = "flake:sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    # nixpak.url = "github:nixpak/nixpak";
    # nixpak.inputs.flake-parts.follows = "flake-parts";
    # nixpak.inputs.nixpkgs.follows = "nixpkgs";

    # customizations
    # themes etc

    # applications and utilities
    # nixpkgs-python.url = "github:cachix/nixpkgs-python";

    # linux only
    disko.url = "flake:disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    microvm.inputs.flake-utils.follows = "flake-utils";
    nixos-hardware.url = "flake:nixos-hardware";
    # nixos-generators.url = "github:nix-community/nixos-generators";
    # nixos-generators.inputs.nixlib.follows = "nixpkgs-lib";
    # nixos-generators.inputs.nixpkgs.follows = "nixpkgs-24-05";
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          flake-parts.flakeModules.modules
          ./lib/flake-modules/lib.nix
          ./lib/flake-modules/overlays.nix
          ./lib/flake-modules/pkgs.nix
          ./lib/flake-modules/shells.nix
          ./lib/flake-modules/formatter.nix
          ./lib/flake-modules/modules.nix
          ./lib/flake-modules/disko-configurations.nix
          ./lib/flake-modules/nixos-configurations.nix
        ];

        debug = true;

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        flake = {
          nixConfig = (import ./flake.nix).nixConfig;
        };

        perSystem =
          { self', ... }:
          {
            devShells.default = self'.devShells.nixos;
          };
      }
    );
}
