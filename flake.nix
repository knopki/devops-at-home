{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  inputs =
    {
      nixos.url = "nixpkgs/nixos-unstable"; # TODO: migrate to the stable
      override.url = "nixpkgs/nixpkgs-unstable";
      ci-agent = {
        url = "github:hercules-ci/hercules-ci-agent";
        inputs = { nix-darwin.follows = "darwin"; flake-compat.follows = "flake-compat"; nixos-20_09.follows = "nixos"; nixos-unstable.follows = "override"; };
      };
      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "nixos";
      deploy = {
        url = "github:serokell/deploy-rs";
        inputs = { flake-compat.follows = "flake-compat"; naersk.follows = "naersk"; nixpkgs.follows = "nixos"; utils.follows = "utils"; };
      };
      devshell.url = "github:numtide/devshell";
      flake-compat.url = "github:BBBSnowball/flake-compat/pr-1";
      flake-compat.flake = false;
      home.url = "github:nix-community/home-manager/release-21.05";
      home.inputs.nixpkgs.follows = "nixos";
      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "override";
      nixos-hardware.url = "github:nixos/nixos-hardware";
      utils.url = "github:numtide/flake-utils";
      pkgs.url = "path:./pkgs";
      pkgs.inputs.nixpkgs.follows = "nixos";
      sops-nix.url = "github:Mic92/sops-nix";
      sops-nix.inputs.nixpkgs.follows = "nixos";

      # emacs
      doom-emacs.url = "github:hlissner/doom-emacs/develop";
      doom-emacs.flake = false;
      emacs-overlay.url = "github:nix-community/emacs-overlay";
      nix-doom-emacs.url = "github:vlaci/nix-doom-emacs/master";
      nix-doom-emacs.inputs.nixpkgs.follows = "nixos";
      nix-doom-emacs.inputs.emacs-overlay.follows = "emacs-overlay";
      nix-doom-emacs.inputs.doom-emacs.follows = "doom-emacs";
      nix-doom-emacs.inputs.flake-utils.follows = "utils";
    };

  outputs = inputs@{ deploy, nixos, nur, self, utils, ... }:
    let
      lib = import ./lib { inherit self nixos utils inputs; };
    in
    lib.mkFlake
      {
        inherit self;
        hosts = ./hosts;
        packages = import ./pkgs;
        suites = import ./profiles/suites.nix;
        extern = import ./extern;
        overrides = import ./extern/overrides.nix;
        overlays = ./overlays;
        profiles = ./profiles;
        userProfiles = ./users/profiles;
        modules = import ./modules/module-list.nix;
        userModules = import ./users/modules/module-list.nix;
      } // {
      inherit lib;
      defaultTemplate = self.templates.flk;
      templates.flk.path = ./.;
      templates.flk.description = "flk template";
    };
}
