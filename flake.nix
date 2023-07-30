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
    nixpkgs-23-05.url = "nixpkgs/nixos-23.05";
    nixpkgs.follows = "nixpkgs-23-05";
    nixpkgsUnstable.url = "nixpkgs/nixos-unstable";

    home-23-05.url = "github:nix-community/home-manager/release-23.05";
    home-23-05.inputs.nixpkgs.follows = "nixpkgs-23-05";
    home.follows = "home-23-05";

    oldDigga.url = "./old-digga";

    flake-parts.url = "github:hercules-ci/flake-parts";
    haumea.url = "github:nix-community/haumea";
    # colmena.url = "github:zhaofengli/colmena";

    devshell.url = "github:numtide/devshell";
    # nix2container.url = "github:nlewo/nix2container";
    # mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    # naersk.url = "github:nmattia/naersk";

    # treefmt-nix.url = "github:numtide/treefmt-nix";
    nvfetcher.url = "github:berberman/nvfetcher";

    # agenix.url = "github:ryantm/agenix";

    # simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    # nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
    # mms.url = "github:mkaito/nixos-modded-minecraft-servers";
  };

  outputs = {
    self,
    flake-parts,
    haumea,
    nixpkgs,
    devshell,
    nvfetcher,
    oldDigga,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({moduleWithSystem, ...}: {
      imports = [
        devshell.flakeModule
    #     treefmt-nix.flakeModule
      ];

      debug = true;

      systems = ["x86_64-linux"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
    #     packages = import ./pkgs {inherit pkgs;};

    #     treefmt = {
    #       programs.alejandra.enable = true;
    #       flakeFormatter = true;
    #       projectRootFile = "flake.nix";
    #     };

        devshells.default = {pkgs, ...}: {
          commands = [
            {package = pkgs.nixUnstable;}
    #         {package = inputs'.agenix.packages.default;}
    #         {package = inputs'.colmena.packages.colmena;}
          ];
        };

        # homeConfigurations
      };

      flake.nixosConfigurations = {
        alien = oldDigga.nixosConfigurations.alien.config.system.build.toplevel;
        # // nixpkgs.lib.nixosSystem {
          # system is not needed with freshly generated hardware-configuration.nix
          # system = "x86_64-linux";  # or set nixpkgs.hostPlatform in a module.
        #   modules = [
        #   ];
        # };
      };

      # flake.nixosModules = {
    #     seafdav = ./modules/seafdav.nix;
    #     hugo-websites = ./modules/website.nix;
      # };

    #   flake.nixosProfiles = haumea.lib.load {
    #     src = ./profiles;
    #     loader = haumea.lib.loaders.path;
    #   };
    #   flake.nixosSuites = let
    #     suites = self.nixosSuites;
    #   in
    #     with self.nixosProfiles; {
    #       base = [core.default users.root users.pachums users.rightleftspin nfs];
    #       media = with media; [wordpress photoprism];

    #       network = with networking; with ci; [common wireguard nix-serve];
    #       backups = with backup; [common onedrive];
    #       cloud = with cloud; [nextcloud collabora seafile suites.media etebase vaultwarden];
    #       comms = with matrix; with mail; [coturn synapse appservices backend web];

    #       myrdd = with suites; nixpkgs.lib.flatten [base network cloud comms vpsadminos backups minecraft];
    #     };

    #   flake.colmena = {
    #     meta = {
    #       nixpkgs = import nixpkgs {
    #         system = "x86_64-linux";
    #         config.allowUnfree = true;
    #       };
    #       specialArgs.suites = self.nixosSuites;
    #     };

    #     defaults = moduleWithSystem (
    #       perSystem @ {
    #         inputs',
    #         self',
    #       }: {lib, ...}: {
    #         imports =
    #           [
    #             agenix.nixosModules.default
    #             simple-nixos-mailserver.nixosModules.mailserver
    #             nix-matrix-appservices.nixosModule
    #             mms.module
    #           ]
    #           ++ lib.attrValues self.nixosModules;
    #         _module.args = {
    #           inputs = perSystem.inputs';
    #           self = self // perSystem.self'; # to preserve original attributes in self like outPath
    #         };
    #         deployment = {
    #           buildOnTarget = true;
    #           targetUser = null;
    #         };
    #       }
    #     );
    #     myrdd = {...}: {
    #       imports = [
    #         ./hosts/myrdd.nix
    #       ];
    #     };
    #   };
    });
}
