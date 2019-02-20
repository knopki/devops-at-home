{ config, pkgs, lib, username, ... }:
with builtins; {
  groups = {
    "${username}" = {
      name = "${username}";
      gid = 1000;
    };
  };

  hm = lib.mkMerge [
    # common
    (import ../cachedirs.nix { inherit config lib username; })
    (import ../fzf.nix { })
    (import ../profile.nix { })
    (import ../readline.nix { })
    (import ../ssh.nix { })
    (import ../xdg.nix { })
    # specific
    (import ./env.nix { inherit config pkgs lib username; })
    (import ./ssh.nix { })
    (import ./tmux.nix { inherit config pkgs lib username; })
    (import ./zsh.nix { inherit config pkgs lib username; })
    {
      home.language.monetary = "ru_RU.UTF-8";
      home.language.time = "ru_RU.UTF-8";
      home.stateVersion = "18.09";
    }
  ];

  systemUser = {
    createHome = true;
    description = "Sergey Korolev";
    extraGroups = [
      "adbusers"
      "audio"
      "disk"
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
      vscode
      yarn
      youtube-dl
    ];
    shell = pkgs.zsh;
    uid = 1000;
  };
}
