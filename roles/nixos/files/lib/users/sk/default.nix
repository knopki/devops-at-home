{ config, pkgs, lib, username, ... }:
with builtins; {
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
    (import ../fish.nix { inherit config pkgs lib username; })
    (import ../fzf.nix { })
    (import ../git.nix { })
    (import ../gpg-agent.nix { })
    (import ../npm.nix { })
    (import ../readline.nix { })
    (import ../ssh.nix { inherit config username; })
    (import ../xdg.nix { inherit config username; })
    (import ../zsh.nix { inherit config pkgs lib username; })
    # specific
    (import ./env.nix { inherit config pkgs lib username; })
    (import ./fish.nix { inherit config pkgs lib username; })
    (import ./git.nix { })
    (import ./gnome.nix { inherit config username; })
    (import ./gnupg.nix { })
    (import ./termite.nix { })
    (import ./vscode.nix { inherit config username; })
    (import ./tmux.nix { inherit config pkgs lib username; })
    (import ./qt.nix { inherit config lib username; })
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
