{ config, lib, pkgs, self, username ? "sk", usr, ... }:
with lib;
let
  sshKeys = import ../secrets/ssh_keys.nix;
  isWorkstation = config.meta.tags.isWorkstation;
  selfHM = config.home-manager.users."${username}";
in
{
  users.groups."${username}" = {
    name = username;
    gid = 1000;
  };

  users.users."${username}" = {
    description = "Sergey Korolev";
    extraGroups = [
      "adbusers"
      "audio"
      "dialout"
      "disk"
      "docker"
      "input"
      "libvirtd"
      "mlocate"
      "networkmanager"
      "pulse"
      "sound"
      "users"
      "video"
      "wheel"
      "wireshark"
    ];
    group = username;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ sshKeys.sk ];
    passwordFile = "/var/secrets/sk_password";
    shell = pkgs.fish;
    uid = 1000;
  };

  home-manager.users = usr.utils.mkHM { inherit username config; } {
    home.language.monetary = "ru_RU.UTF-8";
    home.language.time = "ru_RU.UTF-8";
    home.sessionVariables = {
      TERMINAL = "alacritty";
      PATH = "${selfHM.home.homeDirectory}/.local/bin:${selfHM.xdg.dataHome}/npm/bin:\${PATH}";
    };
    meta.tags = getAttrs [ "isKVMGuest" "isWorkstation" ] config.meta.tags;
    meta.machine = config.meta.machine;
    knopki = {
      alacritty.enable = isWorkstation;
      cachedirs = mkIf isWorkstation [
        "${selfHM.xdg.cacheHome}"
        "${selfHM.xdg.configHome}/Code"
        "${selfHM.xdg.configHome}/Marvin"
        "${selfHM.xdg.configHome}/Postman"
        "${selfHM.xdg.configHome}/chromium"
        "${selfHM.xdg.configHome}/epiphany/gsb-threats.db-journalnfig"
        "${selfHM.xdg.configHome}/gcloud/logs"
        "${selfHM.xdg.configHome}/simpleos"
        "${selfHM.xdg.configHome}/skypeforlinux"
        "${selfHM.xdg.configHome}/transmission/resume"
        "${selfHM.xdg.dataHome}/Anki"
        "${selfHM.xdg.dataHome}/TelegramDesktop"
        "${selfHM.xdg.dataHome}/Trash"
        "${selfHM.xdg.dataHome}/containers"
        "${selfHM.xdg.dataHome}/fish/generated_completions"
        "${selfHM.xdg.dataHome}/flatpak"
        "${selfHM.xdg.dataHome}/gvfs-metadata"
        "${selfHM.xdg.dataHome}/npm"
        "${selfHM.xdg.dataHome}/tmux"
        "${selfHM.xdg.dataHome}/tracker/data"
        "${selfHM.xdg.dataHome}/vim"
        ".kube/cache"
        ".kube/http-cache"
        ".minikube"
        ".mozilla/firefox/Crash Reports"
        ".node-gyp"
        ".vscode"
        "downloads"
      ];
      chromium.enable = isWorkstation;
      curl.enable = true;
      direnv.enable = true;
      emacs.enable = isWorkstation;
      env = {
        graphics = isWorkstation;
      };
      fish.enable = true;
      firefox = {
        enable = isWorkstation;
        mime = isWorkstation;
      };
      git.enable = true;
      gnome = {
        enable = isWorkstation;
        mime = isWorkstation;
      };
      htop.enable = true;
      minikube.enable = isWorkstation;
      neovim.enable = true;
      npmrc.enable = isWorkstation;
      readline.enable = true;
      ssh.enable = true;
      swaywm.enable = isWorkstation;
      tmux.enable = true;
      vscode.enable = isWorkstation;
      wine.enable = isWorkstation;
      wget.enable = true;
      qt.enable = isWorkstation;
    };
    programs.git = {
      signing = {
        key = "58A58B6FD38C6B66";
        signByDefault = true;
      };
      userEmail = "korolev.srg@gmail.com";
      userName = "Sergey Korolev";
      extraConfig.credential.helper =
        mkIf isWorkstation "!${pkgs.gopass}/bin/gopass git-credential $@";
    };
    programs.gpg = {
      enable = true;
      settings.default-key = "58A58B6FD38C6B66";
    };
    systemd.user.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "us,ru";
      XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    };
    xdg = {
      enable = true;
      configFile."user-dirs.locale".text = "en_US";
      configFile."mimeapps.list".force = true;
      userDirs = {
        enable = isWorkstation;
        desktop = "${selfHM.home.homeDirectory}/desktop";
        documents = "${selfHM.home.homeDirectory}/docs";
        download = "${selfHM.home.homeDirectory}/downloads";
        music = "${selfHM.home.homeDirectory}/music";
        pictures = "${selfHM.home.homeDirectory}/pics";
        publicShare = "${selfHM.home.homeDirectory}/public";
        templates = "${selfHM.home.homeDirectory}/templates";
        videos = "${selfHM.home.homeDirectory}/videos";
      };
    };

    systemd.user.tmpfiles.rules = [
      "e ${selfHM.xdg.userDirs.download} - - - 30d"
      "e ${selfHM.xdg.userDirs.download}/*.torrent - - - 1d"
    ];
  };

  system.activationScripts = {
    linger-sk = ''
      #!/usr/bin/env sh
      ${pkgs.systemd}/bin/loginctl enable-linger ${username} || true
    '';
  };
}
