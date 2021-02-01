{ config, lib, pkgs, ... }@args:
with lib;
let
  cfg = config.knopki.users.sk;
  isWorkstation = config.meta.tags.isWorkstation;
  selfHM = config.home-manager.users."${cfg.username}";
  defaultSopsFile = { format = "yaml"; sopsFile = ./secrets/secrets.yaml; };
in
{
  knopki.users.sk = {
    username = mkDefault "sk";
    uid = mkDefault 1000;
    gid = mkDefault 1000;
    linger.enable = mkDefault true;
  };

  sops.secrets.sk-user-password = defaultSopsFile;

  users.users."${cfg.username}" = mkIf cfg.enable {
    description = "Sergey Korolev";
    extraGroups = with config.users.groups; [
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
      keys.name
    ];
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ ./secrets/id_rsa.pub ];
    passwordFile = mkDefault config.sops.secrets.sk-user-password.path;
  };

  home-manager.users."${cfg.username}" = mkIf cfg.enable {
    imports = [ ./kopia.nix ];
    theme = {
      enable = true;
      preset = "dracula";
      fonts = {
        monospace = {
          family = "FiraCode Nerd Font Mono";
          size = 12;
          packages = with pkgs; [
            (nerdfonts.override { fonts = [ "FiraCode" ]; })
            fira-code-symbols
          ];
        };
      };
    };
    home.language.monetary = "ru_RU.UTF-8";
    home.language.time = "ru_RU.UTF-8";
    home.sessionVariables = {
      PATH = "${selfHM.home.homeDirectory}/.local/bin:${selfHM.xdg.dataHome}/npm/bin:\${PATH}";
    };
    knopki = {
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
    programs = {
      alacritty = {
        enable = isWorkstation;
        settings = {
          background_opacity = 0.9;
        };
      };
      feh.enable = isWorkstation;
      git = {
        signing = {
          key = selfHM.programs.gpg.settings.default-key;
          signByDefault = true;
        };
        userEmail = "korolev.srg@gmail.com";
        userName = "Sergey Korolev";
      };
      gpg = {
        enable = true;
        settings.default-key = "58A58B6FD38C6B66";
      };
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

    systemd.user.sessionVariables = {
      TERMINAL = "alacritty -e";
    };
    systemd.user.tmpfiles.rules = [
      "e ${selfHM.xdg.userDirs.download} - - - 30d"
      "e ${selfHM.xdg.userDirs.pictures}/screenshots - - - 30d"
    ];
  };
}
