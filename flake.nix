{
  description = "Configuration management of the my personal machines, my dotfiles, my other somethings.";

  inputs =
    {
      nixos.url = "nixpkgs/release-21.11";
      latest.url = "nixpkgs/nixos-unstable"; # not very latest please
      digga.url = "github:divnix/digga/develop";

      ci-agent = {
        url = "github:hercules-ci/hercules-ci-agent";
        inputs = { nix-darwin.follows = "darwin"; nixos-20_09.follows = "nixos"; nixos-unstable.follows = "latest"; };
      };
      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "nixos";
      home.url = "github:nix-community/home-manager/release-21.11";
      home.inputs.nixpkgs.follows = "nixos";
      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "latest";
      nixos-hardware.url = "github:nixos/nixos-hardware";

      pkgs.url = "path:./pkgs";
      pkgs.inputs.nixpkgs.follows = "nixos";

      sops-nix.url = "github:Mic92/sops-nix";
      sops-nix.inputs.nixpkgs.follows = "nixos";

      # emacs
      emacs-overlay.url = "github:nix-community/emacs-overlay";
      nix-doom-emacs.url = "github:vlaci/nix-doom-emacs/develop";
      org-mode.url = "github:emacs-straight/org-mode/release_9.5.1";
      org-mode.flake = false;
      ws-butler.url = "github:hlissner/ws-butler/572a10c11b6cb88293de48acbb59a059d36f9ba5";
      ws-butler.flake = false;
      evil-escape.url = "github:hlissner/evil-escape/819f1ee1cf3f69a1ae920e6004f2c0baeebbe077";
      evil-escape.flake = false;
      evil-textobj-anyblock.url = "github:willghatch/evil-textobj-anyblock/fix-inner-block";
      evil-textobj-anyblock.flake = false;
      evil-quick-diff.url = "github:rgrinberg/evil-quick-diff/69c883720b30a892c63bc89f49d4f0e8b8028908";
      evil-quick-diff.flake = false;
      nix-doom-emacs.inputs.nixpkgs.follows = "nixos";
    };

  outputs =
    { self
    , pkgs
    , digga
    , nixos
    , ci-agent
    , home
    , nixos-hardware
    , nur
    , sops-nix
    , emacs-overlay
    , nix-doom-emacs
    , agenix
    , ...
    } @ inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          imports = [ (digga.lib.importers.overlays ./overlays) ];
          overlays = [
            ./pkgs/default.nix
            pkgs.overlay # for `srcs`
            nur.overlay
            sops-nix.overlay
            emacs-overlay.overlay
            agenix.overlay
          ];
        };
        latest = { };
      };

      lib = import ./lib { lib = digga.lib // nixos.lib; };

      sharedOverlays = [
        (final: prev: {
          lib = prev.lib.extend (lfinal: lprev: {
            our = self.lib;
          });
        })
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          modules = ./modules/module-list.nix;
          externalModules = [
            {
              _module.args.ourLib = self.lib;
              home-manager.extraSpecialArgs.modulesPath = "${home.outPath}/modules";
            }
            ci-agent.nixosModules.agent-profile
            home.nixosModules.home-manager
            agenix.nixosModules.age
            sops-nix.nixosModules.sops
            ./modules/customBuilds.nix
          ];
        };

        imports = [ (digga.lib.importers.hosts ./hosts) ];
        hosts = {
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
          profiles = digga.lib.importers.rakeLeaves ./profiles // {
            users = digga.lib.importers.rakeLeaves ./users;
          };
          suites = with profiles; rec {
            base = [ core programs.neovim users.root ]
              ++ (with cachix; [ nix-community nrdxp ]);

            workstation = base ++ [
              meta.suites.workstation
              desktop.essentials
              desktop.kde
              fonts
              misc.earlyoom
            ] ++ (with programs; [
              three-de
              chat
              cryptowallets
              downloaders
              image-viewers
              image-editors
              video-player
              video-editor
              office
              music
              passwords
              remote
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
            ] ++ (with programs; [ downloaders image-viewers video-player music ]);
          };
        };
      };

      home = {
        modules = ./users/modules/module-list.nix;
        externalModules = [
          {
            _module.args.ourLib = self.lib;
            _module.args.inputs = inputs;
          }
          nix-doom-emacs.hmModule
        ];
        importables = rec {
          profiles = digga.lib.importers.rakeLeaves ./users/profiles;
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

      devshell = {
        externalModules = { pkgs, ... }: {
          packages = with pkgs; [
            # agenix
            sops
            sops-init-gpg-key
            ssh-to-pgp
          ];

          env = [
            {
              name = "sopsPGPKeyDirs";
              value = "./secrets/keys/hosts ./secrets/keys/users";
            }
          ];

          devshell.startup = {
            sops.text = ''
              source ${pkgs.sops-pgp-hook.outPath}/nix-support/setup-hook
              sopsPGPHook
            '';
          };

          commands = with pkgs; [
            {
              name = "sops-edit";
              category = "secrets";
              command = "${pkgs.sops}/bin/sops $@";
              help = "sops-edit <secretFileName>.yaml | Edit secretFile with sops-nix";
            }
            {
              name = "ae";
              category = "secrets";
              command = "${pkgs.agenix}/bin/agenix -e $@";
              help = "agenix edit file";
            }
          ];
        };
      };

      homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };

      defaultTemplate = self.templates.flk;
      templates.flk.path = ./.;
      templates.flk.description = "flk template";

    };
}
