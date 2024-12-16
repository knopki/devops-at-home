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
    # nixos-23-05.url = "github:divnix/blank";
    nixos-23-11.url = "github:divnix/blank";
    nixos.follows = "nixos-23-11";
    nixpkgs.follows = "nixos";
    latest.url = "github:divnix/blank";
    unstable.url = "github:divnix/blank";

    nixlib.url = "github:divnix/blank";

    flake-utils.url = "github:divnix/blank";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    digga.url = "github:divnix/digga/54ede8e591d288c176a09d6fcf4b123896c0bf0f";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixpkgs-unstable.follows = "latest";
    digga.inputs.nixlib.follows = "nixlib";
    digga.inputs.home-manager.follows = "home";
    digga.inputs.deploy.follows = "deploy";
    digga.inputs.flake-compat.follows = "flake-compat";

    # home-23-05.url = "github:divnix/blank";
    # home-23-05.inputs.nixpkgs.follows = "nixos-23-05";
    # home.follows = "home-23-05";
    home-23-11.url = "github:divnix/blank";
    home-23-11.inputs.nixpkgs.follows = "nixos-23-11";
    home.follows = "home-23-11";

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
    # sops-nix.inputs.nixpkgs.follows = "nixos-23-05";
    # sops-nix.inputs.nixpkgs-stable.follows = "nixos-23-05";
    sops-nix.inputs.nixpkgs.follows = "nixos-23-11";
    sops-nix.inputs.nixpkgs-stable.follows = "nixos-23-11";

    nur.url = "github:nix-community/NUR";
  };

  outputs = {
    self,
    digga,
    nixos,
    home,
    nixos-hardware,
    nur,
    agenix,
    sops-nix,
    ...
  } @ inputs:
    digga.lib.mkFlake {
      inherit self inputs;

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
        latest = {
          # config = {
          #   # allowUnfree = true;
          #   permittedInsecurePackages = [
          #     "betterbird-115.9.0"
          #     "betterbird-unwrapped-115.9.0"
          #   ];
          # };
        };
        unstable = {};
      };

      lib = import ./lib {lib = digga.lib // nixos.lib;};

      sharedOverlays = [
        (_final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (_lfinal: _lprev: {
            our = self.lib;
          });
        })
      ];

      nixos = import ./nixos;

      home = import ./home;

      devshell = ./shell;

      homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;
    };
}
