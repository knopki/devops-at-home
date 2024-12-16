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
    ];
  };

  inputs = {
    # nixpkgs
    # nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-23-11.url = "nixpkgs/nixos-23.11";
    nixpkgs-24-05.url = "nixpkgs/nixos-24.05";
    nixpkgs-24-11.url = "nixpkgs/nixos-24.11";
    nixpkgs.follows = "nixpkgs-24-11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # core modules and libraries
    flake-parts.url = "github:hercules-ci/flake-parts";
    haumea.url = "github:nix-community/haumea/v0.2.2";
    flake-utils.url = "github:numtide/flake-utils";
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    home-23-11.inputs.nixpkgs.follows = "nixpkgs-23-11";
    home-23-11.url = "github:nix-community/home-manager/release-23.11";
    home-24-05.inputs.nixpkgs.follows = "nixpkgs-24-05";
    home-24-05.url = "github:nix-community/home-manager/release-24.05";
    home-24-11.inputs.nixpkgs.follows = "nixpkgs-24-11";
    home-24-11.url = "github:nix-community/home-manager/release-24.11";
    home.follows = "home-24-05";
    # impermanence.url = github:nix-community/impermanence;
    sops-nix.url = "github:Mic92/sops-nix/2168851d58595431ee11ebfc3a49d60d318b7312";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.url = "github:divnix/blank";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # customizations
    # themes etc

    # applications and utilities

    # linux only
    disko.url = "github:nix-community/disko/v1.8.2";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # microvm.url = github:astro/microvm.nix;
    # microvm.inputs.nixpkgs.follows = "nixpkgs";
    # microvm.inputs.flake-utils.follows = "flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware/0ccdd2705669d68bcafd15f45a70ea3c6df57b60";
    # nixos-generators.url = "github:nix-community/nixos-generators";
    # nixos-generators.inputs.nixlib.follows = "nixpkgs-lib";
    # nixos-generators.inputs.nixpkgs.follows = "nixpkgs-24-05";
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, ... }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules = rec {
          shells = importApply ./shells/flake-module.nix { };
          default = shells;
        };
      in
      {
        imports = [
          flake-parts.flakeModules.flakeModules
          flake-parts.flakeModules.modules
          ./lib/flake-module.nix
          ./pkgs/flake-module.nix
          flakeModules.shells
          ./nixos/flake-module.nix
          ./home/flake-module.nix
        ];

        debug = true;

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        flake = {
          inherit flakeModules;
        };

        perSystem =
          { self', ... }:
          {
            devShells.default = self'.devShells.devshells-nixos;
          };
      }
    );
}
# disko
# lanzaboote
# generators
#
# nixos-hardware
# impermanence (and https://grahamc.com/blog/erase-your-darlings)
#
# nix-init
# nixvim
#
# namaka / nixt
# nurl (instead of nvfetcher)
# nix-index-database
# nixos-anywhere
# nix2container
#
#
# wrapper-manager
# helix
# nixago
# sudo -> doas
#
# zfs
# /boot formatted vfat for EFI, or ext4 for BIOS
# and zfs
# https://nixos.wiki/wiki/ZFS
# set disc scheduler to none
# The ZFS dataset partition.
# compression=on
# mountpoint=legacy (not sure)
# tank/
# ├── local
# │   └── nix atime=off
# ├── system
# │   ├── var xattr=sa, acltype=posixacl
# │   └── root
# └── user
#     └── home
#
# https://github.com/ne9z/dotfiles-flake/blob/openzfs-guide/hosts/exampleHost/sshUnlock.txt
# 	-o ashift=12 \
#	-o autotrim=on \
#	-O acltype=posixacl \
#	-O compression=zstd \
#	-O dnodesize=auto -O normalization=formD \
#	-O relatime=on \
#	-O xattr=sa \
#	-O checksum=edonr \
