{ config, lib, pkgs, ... }:
with lib;
let
  username = "sk";
  self = local.users.users."${username}";
  selfHM = config.home-manager.users."${username}";
  isWorkstation = config.local.roles.workstation.enable;
  pathNpmPart =
    if selfHM.local.jsdev.enable then ":${selfHM.xdg.dataHome}/npm/bin" else "";
in
{
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
        "mlocate"
        "networkmanager"
        "wireshark"
      ];
      group = "${username}";
      passwordFile = "/var/secrets/sk_password";
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
          PATH =
            "${selfHM.home.homeDirectory}/.local/bin${pathNpmPart}:\${PATH}";
          TERMINAL = "alacritty";
        };

        local = {
          alacritty.enable = isWorkstation;
          amperka-dev.enable = any (x: x == config.networking.hostName) [ "alien" "oberon" ];
          cachedirs = mkIf isWorkstation [
            ".kube/cache"
            ".kube/http-cache"
            ".minikube"
            ".mozilla/firefox/Crash Reports"
            ".node-gyp"
            ".vscode"
            "${selfHM.xdg.cacheHome}"
            "${selfHM.xdg.configHome}/chromium"
            "${selfHM.xdg.configHome}/Code"
            "${selfHM.xdg.configHome}/epiphany/gsb-threats.db-journalnfig"
            "${selfHM.xdg.configHome}/gcloud/logs"
            "${selfHM.xdg.configHome}/Marvin"
            "${selfHM.xdg.configHome}/Postman"
            "${selfHM.xdg.configHome}/simpleos"
            "${selfHM.xdg.configHome}/skypeforlinux"
            "${selfHM.xdg.configHome}/transmission/resume"
            "${selfHM.xdg.dataHome}/Anki"
            "${selfHM.xdg.dataHome}/containers"
            "${selfHM.xdg.dataHome}/fish/generated_completions"
            "${selfHM.xdg.dataHome}/flatpak"
            "${selfHM.xdg.dataHome}/gvfs-metadata"
            "${selfHM.xdg.dataHome}/npm"
            "${selfHM.xdg.dataHome}/TelegramDesktop"
            "${selfHM.xdg.dataHome}/tmux"
            "${selfHM.xdg.dataHome}/tracker/data"
            "${selfHM.xdg.dataHome}/Trash"
            "${selfHM.xdg.dataHome}/vim"
            "downloads"
          ];
          chromium.enable = isWorkstation;
          devops.enable = isWorkstation;
          env.graphics = isWorkstation;
          firefox.enable = isWorkstation;
          fish.enable = true;
          gnome.enable = isWorkstation;
          jsdev.enable = isWorkstation;
          neovim.enable = true;
          nixdev.enable = isWorkstation;
          qt.enable = isWorkstation;
          swaywm.enable = isWorkstation;
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
        xdg.userDirs = {
          desktop = "${selfHM.home.homeDirectory}/desktop";
          documents = "${selfHM.home.homeDirectory}/docs";
          download = "${selfHM.home.homeDirectory}/downloads";
          music = "${selfHM.home.homeDirectory}/music";
          pictures = "${selfHM.home.homeDirectory}/pics";
          publishShare = "${selfHM.home.homeDirectory}/public";
          templates = "${selfHM.home.homeDirectory}/templates";
          videos = "${selfHM.home.homeDirectory}/videos";
        };
      };
      isAdmin = true;
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = mkDefault [ ./sk_id_rsa.pub ];

      setupUser = true;
      shell = pkgs.fish;
      uid = 1000;
    };

    system.activationScripts = {
      linger-sk = ''
        #!/usr/bin/env sh
        ${pkgs.systemd}/bin/loginctl enable-linger ${username}
      '';
    };
  };
}
