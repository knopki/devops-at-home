{ config, options, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkIf mkMerge optionals;
  cfg = config.users.users.sk;
  selfHM = config.home-manager.users.sk;
  isWorkstation = config.meta.suites.workstation;
  isDevbox = config.meta.suites.devbox;
  isGamestation = config.meta.suites.gamestation;
  isGraphical = isWorkstation || isGamestation;
in
{
  imports = [ ./sops.nix ./vdirsyncer.nix ];

  users.groups.sk.gid = mkDefault 1000;

  users.users.sk = {
    description = "Sergey Korolev";
    uid = mkDefault 1000;
    group = "sk";
    isNormalUser = true;
    passwordFile = mkDefault config.sops.secrets.sk-user-password.path;
    openssh.authorizedKeys.keyFiles = [ ./secrets/id_rsa.pub ];
    extraGroups = with config.users.groups; [
      cfg.group
      "adbusers"
      "audio"
      "dialout"
      "disk"
      "input"
      "libvirtd"
      "mlocate"
      "networkmanager"
      "plugdev"
      "podman"
      "pulse"
      "sound"
      "users"
      "video"
      "wheel"
      "wireshark"
      keys.name
    ];
  };

  systemd.linger.usernames = [ cfg.name ];

  home-manager.users.sk = { suites, ... }: {
    imports = [ ./gpg.nix ]
      ++ suites.base
      ++ optionals isWorkstation suites.workstation
      ++ optionals isDevbox suites.devbox
      ++ optionals isGamestation suites.gamestation
      ++ optionals isGraphical [
      ./alacritty.nix
      ./web.nix
      ./gnome.nix
      ./kde
      ./xdg.nix
    ]
      ++ optionals isWorkstation [
      ./emacs
      ./kopia.nix
    ] ++ optionals isDevbox [
      ./vscode.nix
    ];

    home.packages = with pkgs; [
      du-dust
    ] ++ optionals isWorkstation [
      feh
      gh
    ];

    theme = {
      enable = true;
      preset = "dracula";
      fonts = {
        monospace = {
          family = "FiraCode Nerd Font Mono";
          size = 10;
          packages = with pkgs; [
            (nerdfonts.override { fonts = [ "FiraCode" ]; })
            fira-code-symbols
          ];
        };
      };
      components.plasma.enable = true;
    };

    programs = {
      git = {
        signing = {
          key = selfHM.programs.gpg.settings.default-key;
          signByDefault = true;
        };
        userEmail = "knopki@duck.com";
        userName = "Sergei Korolev";
      };
      password-store.settings.PASSWORD_STORE_KEY = selfHM.programs.gpg.settings.default-key;
    };

    systemd.user.tmpfiles.rules = optionals isWorkstation [
      "e ${selfHM.xdg.userDirs.download} - - - 30d"
      "e ${selfHM.xdg.userDirs.pictures}/screenshots - - - 30d"
    ];
  };
}
