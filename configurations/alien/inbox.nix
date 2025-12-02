{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkBefore mkDefault;
  officePkgs = with pkgs; [
    brave
  ];
in
{
  #
  # Packages
  #

  environment.systemPackages =
    with pkgs;
    [
      # essentials
      gnupg
      starship
      libsecret # secret-tool

      # shell
      atuin
      fishPlugins.fish-you-should-use

      # remote
      mosh
      openssh

      # backups
      btrbk
      restic
      restic-browser
      rustic
      redu
      deja-dup

      # look and feel
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.symbols-only

      # misc
      bees
      tor-browser
      amneziawg-go
      amneziawg-tools
      bottles
      # tailscale
      xorg.xhost
      # yubikey-manager
      httm
      cherry-studio

      # temporary
      impression
    ]
    ++ officePkgs;

  programs = {
    bash = {
      undistractMe.enable = true;
    };
    chromium = {
      enable = true;
      extensions = [
        "npeicpdbkakmehahjeeohfdhnlpdklia" # webrtc network linter
      ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    firefox = {
      enable = true;
      nativeMessagingHosts.packages = [ pkgs.keepassxc ];
      languagePacks = [
        "en-US"
        "ru"
      ];
    };
    fish = {
      enable = true;
      useBabelfish = true;
      interactiveShellInit = ''
        source ${pkgs.ls-colors}/lscolors.csh
      '';
    };
    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };

    iftop.enable = mkDefault true;
    less.lessopen = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    mosh.enable = mkDefault true;
    nh.flake = "/home/sk/dev/knopki/devops-at-home";
    throne = {
      enable = true;
      tunMode.enable = true;
    };
    nix-index.enable = mkDefault true;
    nix-ld = {
      enable = true;
      libraries = [
        # already included:
        #   acl attr bzip2 curl libsodium libssh libxml2 openssl
        #   stdenv.cc.cc systemd util-linux xz zlib zstd
      ];
    };
    starship = {
      enable = true;
      transientPrompt.enable = true;
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      keyMode = "vi";
      newSession = true;
      terminal = "screen-256color";
      plugins = with pkgs.tmuxPlugins; [
        pain-control
        sensible
      ];
      extraConfig = ''
        setw -g mode-keys vi

        # enable activity alerts
        setw -g monitor-activity on
        set -g visual-activity off
        set-option -g bell-action none

        # change terminal info
        set -g set-titles on
        set -g set-titles-string "#T"

        # jump to left/right window
        bind-key -n M-PPage previous-window
        bind-key -n M-NPage next-window

        # mouse
        set -g mouse on

        # mouse scrolling
        bind -n WheelUpPane   if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
        bind -n WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"

        # fix keys
        set-window-option -g xterm-keys on

        # show hostname
        set -g status-right ' #(hostname -s) '

        # clipboard
        set -g set-clipboard external
        bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "${pkgs.xclip}/bin/xclip -i -f -selection primary | ${pkgs.xclip}/bin/xclip -i -selection clipboard"
      '';
    };
  };

  #
  # Nix
  #

  nix = {
    extraOptions = mkBefore ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';
  };

  #
  # Network
  #

  services = {
    envfs.enable = true;
  };

  #
  # Security
  #

  security = {
    polkit.extraConfig = ''
      # NOTE: this is removed because it's allows run0 everything without password
      #   /* Allow users in wheel group to manage systemd units without authentication */
      #   polkit.addRule(function(action, subject) {
      #       if (action.id == "org.freedesktop.systemd1.manage-units" &&
      #           subject.isInGroup("wheel")) {
      #           return polkit.Result.YES;
      #       }
      #   });
    '';

    protectKernelImage = mkDefault true;

    sudo.extraConfig = ''
      Defaults timestamp_timeout=600
    '';
  };

  #
  # Misc
  #
  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  networking = {
    hostId = "ff0b9d65";
    networkmanager.unmanaged = [ "docker0" ];
    search = [
      "lan"
    ];
    firewall = {
      rejectPackets = mkDefault true;
      allowedTCPPorts = [ ];
      allowedTCPPortRanges = [
        {
          from = 6881;
          to = 6889;
        } # torrents
      ];
      allowedUDPPorts = [ ];
      allowedUDPPortRanges = [
        {
          from = 6881;
          to = 6889;
        } # torrents
      ];
      trustedInterfaces = [
        "docker0"
        "ve-+"
      ];
    };
  };

  sops = {
    secrets = {
      nix-github-access-token = { };
      amneziawg-home-conf = { };
    };
    templates."nix-access-tokens.conf".content = ''
      access-tokens = github.com=${config.sops.placeholder.nix-github-access-token}
    '';
  };

  system.tools.nixos-option.enable = false;

  systemd = {
    network = {
      wait-online = {
        anyInterface = true;
        extraArgs = [
          "-i"
          "enp59s0"
          "-i"
          "wlp60s0"
        ];
      };
    };
    services = {
      systemd-networkd = {
        serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
      };
    };
  };

  environment.etc."amnezia/amneziawg/home.conf".source = config.sops.secrets.amneziawg-home-conf.path;
}
