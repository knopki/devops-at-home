{ config, lib, pkgs, ... }:
with lib;
let
  username = "sk";
  self = local.users.users."${username}";
  selfHM = config.home-manager.users."${username}";
in {
  config = mkIf (elem "sk" config.local.users.setupUsers) {
    users.groups = {
      "${username}" = {
        name = "${username}";
        gid = 1000;
      };
    };

    local.users.users."${username}" = {
      createHome = true;
      description = "Sergey Korolev";
      extraGroups = [
        "adbusers"
        "disk"
        "docker"
        "libvirtd"
        "networkmanager"
        "wireshark"
      ];
      group = "${username}";
      hashedPassword = readFile "/etc/nixos/secrets/sk_password";
      home = "/home/${username}";
      home-config = {
        home.file = {
          ".gnupg/gpg.conf".text = ''
            default-key 58A58B6FD38C6B66

            keyserver  hkp://pool.sks-keyservers.net
            use-agent
          '';
        };

        home.sessionVariables = {
          BROWSER = "firefox";
          PATH = "${selfHM.home.homeDirectory}/.local/bin:${selfHM.home.homeDirectory}/.local/npm/bin:\${PATH}";
          TERMINAL = "termite";
        };

        local = {
          cachedirs = [
            ".kube/http-cache"
            ".minikube"
            ".mozilla/firefox/Crash Reports"
            ".node-gyp"
            "${selfHM.xdg.cacheHome}"
            "${selfHM.xdg.configHome}/chromium"
            "${selfHM.xdg.configHome}/Code"
            "${selfHM.xdg.configHome}/epiphany/gsb-threats.db-journalnfig"
            "${selfHM.xdg.configHome}/Marvin"
            "${selfHM.xdg.configHome}/simpleos"
            "${selfHM.xdg.dataHome}/containers"
            "${selfHM.xdg.dataHome}/flatpak"
            "${selfHM.xdg.dataHome}/npm"
            "${selfHM.xdg.dataHome}/TelegramDesktop"
            "${selfHM.xdg.dataHome}/tmux"
            "${selfHM.xdg.dataHome}/Trash"
            "${selfHM.xdg.dataHome}/vim"
            "downloads"
          ];
          desktop-pack.enable = true;
          devops.enable = true;
          env.graphics = true;
          fish.enable = true;
          gnome.enable = true;
          jsdev.enable = true;
          qt.enable = true;
          swaywm.enable = true;
          termite.enable = true;
          tmux.enable = true;
        };
        programs.git = {
          signing = {
            key = "58A58B6FD38C6B66";
            signByDefault = true;
          };
          userEmail = "korolev.srg@gmail.com";
          userName = "Sergey Korolev";
        };
        systemd.user.sessionVariables = {
          PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
          PATH = "${selfHM.home.sessionVariables.PATH}";
          XKB_DEFAULT_LAYOUT = "us,ru";
          XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
        };
      };
      isAdmin = true;
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = mkDefault [ "/etc/nixos/secrets/sk_id_rsa.pub" ];

      setupUser = true;
      shell = pkgs.fish;
      uid = 1000;
    };

    system.activationScripts = {
      linger-sk = ''
        ${pkgs.systemd}/bin/loginctl enable-linger ${username}
      '';
    };
  };
}
