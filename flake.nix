{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  nixConfig = {
    commit-lockfile-summary = "flake: bump inputs";
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    # nixpkgs
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-25-11.url = "nixpkgs/nixos-25.11";
    nixpkgs.follows = "nixpkgs-25-11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # core modules and libraries
    flake-parts.url = "flake:flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    home-25-11.inputs.nixpkgs.follows = "nixpkgs-25-11";
    home-25-11.url = "github:nix-community/home-manager/release-25.11";
    home.follows = "home-25-11";
    sops-nix.url = "flake:sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # linux only
    disko.url = "flake:disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    preservation.url = "github:nix-community/preservation";
    nixos-hardware.url = "flake:nixos-hardware";
    lanzaboote.url = "github:nix-community/lanzaboote/7e031eb535a494582f4fc58735b5aecba7b57058"; # 2026-01-13
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-generators.url = "github:nix-community/nixos-generators";
    # nixos-generators.inputs.nixlib.follows = "nixpkgs-lib";
    # nixos-generators.inputs.nixpkgs.follows = "nixpkgs-24-05";
    # nixpak.url = "github:nixpak/nixpak";
    # nixpak.inputs.flake-parts.follows = "flake-parts";
    # nixpak.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          flake-parts.flakeModules.modules
          ./lib/flake-modules/lib.nix
          ./lib/flake-modules/overlays.nix
          ./lib/flake-modules/pkgs.nix
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
          inherit ((import ./flake.nix)) nixConfig;
        };
      }
    );
}
