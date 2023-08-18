{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # nixpkgs
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-22-11.url = "nixpkgs/nixos-22.11";
    nixpkgs-23-05.url = "nixpkgs/nixos-23.05";
    nixpkgs.follows = "nixpkgs-23-05";
    nixpkgsUnstable.url = "nixpkgs/nixos-unstable";

    # core modules and libraries
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    haumea.inputs.nixpkgs.follows = "nixpkgs-lib";
    haumea.url = "github:nix-community/haumea/v0.2.2";
    home-22-11.inputs.nixpkgs.follows = "nixpkgs-22-11";
    home-22-11.url = "github:nix-community/home-manager/release-22.11";
    home-23-05.inputs.nixpkgs.follows = "nixpkgs-23-05";
    home-23-05.url = "github:nix-community/home-manager/release-23.05";
    home.follows = "home-23-05";
    impermanence.url = "github:nix-community/impermanence";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # customizations
    # themes etc

    # applications and utilities

    # linux only
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    microvm.inputs.flake-utils.follows = "flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixlib.follows = "nixpkgs-lib";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs-23-05";

    # legacy
    oldDigga.url = "path:./old-digga";
    oldDigga.inputs = {
      flake-utils.follows = "flake-utils";
      home-22-11.follows = "home-22-11";
      latest.follows = "nixpkgsUnstable";
      nixlib.follows = "nixpkgs-lib";
      nixos-22-11.follows = "nixpkgs-22-11";
      nixos-generators.follows = "nixos-generators";
      nixos-hardware.follows = "nixos-hardware";
    };

    # nix-doom-emacs
    # sops-nix
    # nix2container.url = "github:nlewo/nix2container";
    # mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    # naersk.url = "github:nmattia/naersk";
    # colmena.url = "github:zhaofengli/colmena";
    # simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    # nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
  };

  outputs = {
    self,
    flake-parts,
    haumea,
    home,
    nixpkgs,
    oldDigga,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        ./flake/lib.nix
        ./flake/shells.nix
        ./flake/pkgs.nix
        ./flake/nixos.nix
      ];

      debug = false;

      systems = ["x86_64-linux" "aarch64-linux"];

      flake.nixosConfigurations = {
        alien = oldDigga.nixosConfigurations.alien;
      };
    });
}
