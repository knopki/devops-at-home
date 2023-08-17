{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://nrdxp.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Track channels with commits tested and built by hydra
    nixos-22-11.url = "github:divnix/blank";
    nixos.follows = "nixos-22-11";
    nixpkgs.follows = "nixos";
    latest.url = "github:divnix/blank";

    nixlib.url = "github:divnix/blank";

    flake-utils.url = "github:divnix/blank";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    digga.url = "github:divnix/digga/54ede8e591d288c176a09d6fcf4b123896c0bf0f";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixlib.follows = "nixlib";
    digga.inputs.home-manager.follows = "home";
    digga.inputs.deploy.follows = "deploy";
    digga.inputs.flake-compat.follows = "flake-compat";
    # digga.inputs.flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

    home-22-11.url = "github:divnix/blank";
    home-22-11.inputs.nixpkgs.follows = "nixos-22-11";
    home.follows = "home-22-11";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";
    deploy.inputs.utils.follows = "flake-utils";
    deploy.inputs.flake-compat.follows = "flake-compat";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixos";

    nixos-hardware.url = "github:divnix/blank";

    nixos-generators.url = "github:divnix/blank";
    nixos-generators.inputs.nixlib.follows = "nixlib";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixos-22-11";
    sops-nix.inputs.nixpkgs-stable.follows = "nixos-22-11";

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixos";
    nix-doom-emacs.inputs.flake-utils.follows = "flake-utils";
    nix-doom-emacs.inputs.flake-compat.follows = "flake-compat";
  };

  outputs = {
    self,
    digga,
    nixos,
    home,
    nixos-hardware,
    nur,
    agenix,
    deploy,
    sops-nix,
    nix-doom-emacs,
    ...
  } @ inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = {allowUnfree = true;};

      channels = {
        nixos = {
          imports = [(digga.lib.importOverlays ./pkgs/overlays)];
          overlays = [
            nur.overlay
            agenix.overlay
            sops-nix.overlay
            ./pkgs/default.nix
          ];
        };
        latest = {};
      };

      lib = import ./lib {lib = digga.lib // nixos.lib;};

      sharedOverlays = [
        (final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (lfinal: lprev: {
            our = self.lib;
          });
        })
      ];

      nixos = import ./nixos;

      home = import ./home;

      devshell = ./shell;

      homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations {};
    };
}
