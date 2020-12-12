{ config, lib, pkgs, ... }@args:
with lib;
let
  cfg = config.knopki.users.sk;
  sshKeys = import ../secrets/ssh_keys.nix;
  isWorkstation = config.meta.tags.isWorkstation;
  selfHM = config.home-manager.users."${cfg.username}";
in
{
  knopki.users.sk = {
    username = mkDefault "sk";
    uid = mkDefault 1000;
    gid = mkDefault 1000;
    linger.enable = mkDefault true;
  };

  users.users."${cfg.username}" = mkIf cfg.enable {
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
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ sshKeys.sk ];
    passwordFile = "/var/secrets/sk_password";
  };

  home-manager.users."${cfg.username}" = mkIf cfg.enable {
    home.language.monetary = "ru_RU.UTF-8";
    home.language.time = "ru_RU.UTF-8";
    home.sessionVariables = {
      TERMINAL = "alacritty";
      PATH = "${selfHM.home.homeDirectory}/.local/bin:${selfHM.xdg.dataHome}/npm/bin:\${PATH}";
    };
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
      direnv.enable = true;
      emacs.enable = isWorkstation;
      firefox.enable = isWorkstation;
      gnome.enable = isWorkstation;
      minikube.enable = isWorkstation;
      neovim.enable = true;
      npmrc.enable = isWorkstation;
      password-store.enable = isWorkstation;
      swaywm.enable = isWorkstation;
      vscode.enable = isWorkstation;
      wine.enable = isWorkstation;
      qt.enable = isWorkstation;
    };
    programs.feh.enable = isWorkstation;
    programs.git = {
      signing = {
        key = selfHM.programs.gpg.settings.default-key;
        signByDefault = true;
      };
      userEmail = "korolev.srg@gmail.com";
      userName = "Sergey Korolev";
    };
    programs.gpg = {
      enable = true;
      settings.default-key = "58A58B6FD38C6B66";
    };
    xdg = {
      enable = true;
      configFile."user-dirs.locale".text = "en_US";
      configFile."mimeapps.list".force = true;
      mimeApps = {
        defaultApplications = {
          "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];
          "application/pdf" = [ "org.pwmt.zathura.desktop" "org.gnome.Evince.desktop" ];
          "x-scheme-handler/mailto" = "org.gnome.Geary.desktop";
        } // (listToAttrs (map (x: nameValuePair x [ "org.gnome.eog.desktop" ]) [
          "image/bmp"
          "image/gif"
          "image/jpeg"
          "image/jpg"
          "image/pjpeg"
          "image/png"
          "image/svg+xml"
          "image/svg+xml-compressed"
          "image/tiff"
          "image/vnd.wap.wbmp"
          "image/x-bmp"
          "image/x-gray"
          "image/x-icb"
          "image/x-icns"
          "image/x-ico"
          "image/x-pcx"
          "image/x-png"
          "image/x-portable-anymap"
          "image/x-portable-bitmap"
          "image/x-portable-graymap"
          "image/x-portable-pixmap"
          "image/x-xbitmap"
          "image/x-xpixmap"
        ])) // (listToAttrs (map (x: nameValuePair x "firefox.desktop") [
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "application/xhtml+xml"
          "application/xml"
          "text/html"
          "x-scheme-handler/ftp"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ]));
      };
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
      "e ${selfHM.xdg.userDirs.pictures}/screenshots - - - 30d"
    ];
  };
}
