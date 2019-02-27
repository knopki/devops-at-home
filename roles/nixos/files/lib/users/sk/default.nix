{ config, pkgs, lib, username, ... }:
let
  selfHM = config.home-manager.users."${username}";
  envd = {
    "00-system" = {
      DBUS_SESSION_BUS_ADDRESS = "${selfHM.home.sessionVariables.DBUS_SESSION_BUS_ADDRESS}";
      PATH = "${selfHM.home.sessionVariables.PATH}";
      XDG_RUNTIME_DIR = "${selfHM.home.sessionVariables.XDG_RUNTIME_DIR}";
    };
    "50-graphics" = {
      __GL_SHADER_DISK_CACHE_PATH = "${selfHM.xdg.cacheHome}/nv";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
      # CLUTTER_BACKEND = "wayland";
      # GDK_BACKEND = "wayland";
      CUDA_CACHE_PATH = "${selfHM.xdg.cacheHome}/nv";
      GTK_RC_FILES = "${selfHM.xdg.configHome}/gtk-1.0/gtkrc";
      GTK2_RC_FILES = "${selfHM.xdg.configHome}/gtk-2.0/gtkrc";
      QT_QPA_PLATFORM = "wayland-egl";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      XDG_CURRENT_DESKTOP = "GNOME";
    };
    "50-keyboard" = {
      XKB_DEFAULT_LAYOUT = "us,ru";
      XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    };
  };
in with builtins; {
  groups = {
    "${username}" = {
      name = "${username}";
      gid = 1000;
    };
  };

  hm = lib.mkMerge (lib.reverseList [
    # common
    (import ../cachedirs.nix { inherit config lib username; })
    (import ../editorconfig.nix { inherit lib; })
    (import ../envd.nix { inherit config envd lib username; })
    (import ../fish.nix { inherit config pkgs lib username; })
    (import ../fzf.nix { })
    (import ../git.nix { })
    (import ../gpg-agent.nix { })
    (import ../npm.nix { inherit config username; })
    (import ../readline.nix { })
    (import ../ssh.nix { inherit config username; })
    (import ../xdg.nix { })
    (import ../zsh.nix { inherit config pkgs lib username; })
    # specific
    (import ./env.nix { inherit config pkgs lib username; })
    (import ./fish.nix { inherit config pkgs lib username; })
    (import ./git.nix { })
    (import ./gnome.nix { inherit config username; })
    (import ./gnupg.nix { })
    (import ./qt.nix { inherit config lib username; })
    (import ./swaywm.nix { inherit config lib pkgs username; })
    (import ./termite.nix { })
    (import ./tmux.nix { inherit config pkgs lib username; })
    (import ./vscode.nix { inherit config username; })
    (import ./zsh.nix { inherit config pkgs lib username; })
    {
      home.language.monetary = "ru_RU.UTF-8";
      home.language.time = "ru_RU.UTF-8";
      home.stateVersion = "18.09";
      nixpkgs.config = config.nixpkgs.config;
      services.gnome-keyring = {
        enable = true;
        components = ["pkcs11" "secrets" "ssh"];
      };
    }
  ]);

  systemUser = {
    createHome = true;
    description = "Sergey Korolev";
    extraGroups = [
      "adbusers"
      "audio"
      "disk"
      "docker"
      "input"
      "libvirtd"
      "networkmanager"
      "pulse"
      "sound"
      "users"
      "video"
      "wheel"
      "wireshark"
    ];
    group = "${username}";
    hashedPassword = readFile "/etc/nixos/secrets/sk_password";
    home = "/home/${username}";
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ "/etc/nixos/secrets/sk_id_rsa.pub" ];
    packages = with pkgs; [
      anki
      appimage-run
      blender
      chromium
      darktable
      feh
      firefox
      gimp
      gnome3.rhythmbox
      google-cloud-sdk
      keepassxc
      krita
      kube-score
      kubectl
      kubernetes-helm
      libreoffice-unwrapped
      mpv
      neovim-qt
      nextcloud-client-unwrapped
      nmap-graphical
      pavucontrol
      picard
      playerctl
      remmina
      shfmt
      tdesktop
      telepresence
      tor-browser-bundle-bin
      transmission-gtk
      unstable.kustomize
      unstable.postman
      vscode-with-extensions
      yarn
      youtube-dl
    ];
    shell = pkgs.fish;
    uid = 1000;
  };
}
