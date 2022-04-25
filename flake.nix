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

  inputs =
    {
      # Track channels with commits tested and built by hydra
      nixos-21-11.url = "github:nixos/nixpkgs/nixos-21.11";
      nixos.follows = "nixos-21-11";
      latest.url = "github:nixos/nixpkgs/nixos-unstable";

      digga.url = "github:divnix/digga/v0.11.0";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";
      digga.inputs.deploy.follows = "deploy";

      bud.url = "github:divnix/bud";
      bud.inputs.nixpkgs.follows = "nixos";
      bud.inputs.devshell.follows = "digga/devshell";

      home-21-11.url = "github:nix-community/home-manager/release-21.11";
      home.follows = "home-21-11";
      home.inputs.nixpkgs.follows = "nixos";

      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "nixos";

      deploy.url = "github:serokell/deploy-rs";
      deploy.inputs.nixpkgs.follows = "nixos";

      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixos";

      nvfetcher.url = "github:berberman/nvfetcher";
      nvfetcher.inputs.nixpkgs.follows = "nixos";

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "nixos";

      nixos-hardware.url = "github:nixos/nixos-hardware";

      nixos-generators.url = "github:nix-community/nixos-generators";

      sops-nix.url = "github:Mic92/sops-nix";
      sops-nix.inputs.nixpkgs.follows = "nixos";

      emacs-overlay.url = "github:nix-community/emacs-overlay";
      nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
      nix-doom-emacs.inputs.nixpkgs.follows = "nixos";
    };

  outputs =
    { self
    , digga
    , bud
    , nixos
    , home
    , nixos-hardware
    , nur
    , agenix
    , nvfetcher
    , deploy
    , sops-nix
    , emacs-overlay
    , nix-doom-emacs
    , ...
    } @ inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [
            nur.overlay
            agenix.overlay
            nvfetcher.overlay
            sops-nix.overlay
            emacs-overlay.overlay
            ./pkgs/default.nix
          ];
        };
        latest = { };
      };

      lib = import ./lib { lib = digga.lib // nixos.lib; };

      sharedOverlays = [
        (final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (lfinal: lprev: {
            our = self.lib;
          });
        })
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          imports = [ (digga.lib.importExportableModules ./modules) ];
          modules = [
            { lib.our = self.lib; }
            digga.nixosModules.bootstrapIso
            digga.nixosModules.nixConfig
            home.nixosModules.home-manager
            agenix.nixosModules.age
            bud.nixosModules.bud
            sops-nix.nixosModules.sops
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts) ];
        hosts = {
          NixOS = {};
          alien = {
            modules = with nixos-hardware.nixosModules; [
              common-cpu-intel
              common-gpu-nvidia
              common-pc-laptop
              common-pc-ssd
            ];
          };
        };
        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles // {
            users = digga.lib.rakeLeaves ./users;
          };
          suites = with profiles; rec {
            base = [ core users.root ]
              ++ (with cachix; [ nix-community nrdxp ]);

            workstation = base ++ [
              meta.suites.workstation
              desktop.essentials
              desktop.kde
              fonts
              misc.earlyoom
            ] ++ (with programs; [
              chat
              cryptowallets
              downloaders
              image-editors
              image-viewers
              music
              office
              passwords
              remote
              three-de
              video-editor
              video-player
              web
            ]);

            mobile = base ++ [
              meta.suites.mobile
              laptop
            ];

            devbox = workstation ++ [
              meta.suites.devbox
              ws-virtualization
              dev.nix
            ];

            gamestation = base ++ [
              meta.suites.gamestation
              desktop.essentials
              desktop.kde
              fonts
              games.steam
              misc.earlyoom
              security.disable-mitigations
            ] ++ (with programs; [ downloaders image-viewers video-player music web ]);
          };
        };
      };

      home = {
        imports = [ (digga.lib.importExportableModules ./users/modules) ];
        modules = [
          { lib.our = self.lib; }
          nix-doom-emacs.hmModule
        ];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./users/profiles;
          suites = with profiles; rec {
            base = [ hm ] ++ (with programs; [
              bash
              bat
              curl
              direnv
              fish
              fzf
              git
              htop
              jq
              lesspipe
              readline
              ssh
              tmux
              wget
            ]);

            graphical = base ++ [ desktop.gnome desktop.kde ] ++ (with programs; [
              alacritty
              firefox
              brave
              imv
              spectacle
              zathura
            ]);

            workstation = base ++ graphical ++ [
              ws-mods
              locale.ru-ru
            ] ++ (with programs; [
              password-store
              starship
              vscode
            ]);

            devbox = workstation ++ [
              services.hound
            ] ++ (with programs; [
              cloud-tools
              nodejs
              python
              winbox
            ]);

            gamestation = base ++ graphical ++ [
              locale.ru-ru
            ];
          };
        };
      };

      devshell = ./shell;

      homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };
    };
}
