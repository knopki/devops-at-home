{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkBefore mkDefault;
  mediaPkgs = with pkgs; [
    # darktable
    # digikam
    # rawtherapee
    imgcat
    krita
    mpv-with-plugins
    obs-studio
    picard
    qbittorrent
    # streamrip
    # upscaler # is it needed?
    # upscayl # is it needed?
    yt-dlp
    gallery-dl
    fclones
    fclones-gui
    findimagedupes
    czkawka-full
    imagemagick
    swayimg
    feh
  ];
  officePkgs = with pkgs; [
    aliza
    anki
    anytype
    aspellDicts.en
    aspellDicts.ru
    brave
    img2pdf
    isync
    keepassxc
    khal
    khard
    nextcloud-client
    obsidian
    obsidian-export
    ocrmypdf
    offlineimap
    onlyoffice-desktopeditors
    pdfarranger
    poppler_utils
    qalculate-gtk
    qpdf
    rclone
    seahorse
    weasis
    zotero
  ];
  devPkgs = with pkgs; [
    # tools
    gh
    gnupg
    ripgrep
    android-udev-rules
    arduino-cli
    lazygit
    picotool
    python3
    just

    # editors / IDE
    arduino-ide
    aider-chat-full

    # python
    uv
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
      bat
      binutils
      curl
      dnsutils
      dosfstools
      du-dust
      fd
      file
      gnupg
      gptfdisk
      iputils
      lsof
      ngrep
      pstree
      ranger
      ripgrep
      rsync
      sysstat
      tree
      wget
      chezmoi
      starship

      # shell
      atuin
      fishPlugins.fish-you-should-use
      fishPlugins.forgit

      # messenging
      simplex-chat-desktop
      telegram-desktop
      discord

      # remote
      anydesk
      mosh
      openssh
      remmina

      # backups
      kopia
      flock

      # look and feel
      arc-kde-theme
      arc-theme
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      papirus-icon-theme

      # misc
      tor-browser
      amneziawg-go
      amneziawg-tools
      bottles
      lazydocker
      # tailscale
      xorg.xhost
      revanced-cli
      restic
      rustic-rs
      smartmontools
      yubikey-manager
      vmtouch
      httm
      jq

      # temporary
      usbimager
    ]
    ++ devPkgs
    ++ mediaPkgs
    ++ officePkgs;

  programs = {
    bash = {
      undistractMe.enable = true;
    };
    chromium = {
      enable = true;
      enablePlasmaBrowserIntegration = true;
      extensions = [
        "npeicpdbkakmehahjeeohfdhnlpdklia" # webrtc network linter
      ];
    };
    command-not-found.enable = mkDefault false;
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
      shellAliases = {
        fzf = "fzf-tmux -m";
        grep = "grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
        myip = "curl ifconfig.co";
      };
      shellAbbrs = {
        gco = "git checkout";
        gst = "git status";
        o = "xdg-open";
        rsync-copy = "rsync -avz --progress -h";
        rsync-move = "rsync -avz --progress -h --remove-source-files";
        rsync-synchronize = "rsync -avzu --delete --progress -h";
        rsync-update = "rsync -avzu --progress -h";
      };
      interactiveShellInit = ''
        function fish_hybrid_key_bindings --description \
        "Vi-style bindings that inherit emacs-style bindings in all modes"
            for mode in default insert visual
                fish_default_key_bindings -M $mode
            end
            fish_vi_key_bindings --no-erase
        end
        set -g fish_key_bindings fish_hybrid_key_bindings
        set -g fish_greeting ""
        source ${pkgs.ls-colors}/lscolors.csh
      '';
    };
    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
    };
    htop = {
      enable = true;
      settings = {
        hide_threads = 1;
        hide_userland_threads = 1;
        shadow_other_users = 1;
        show_program_path = 0;
        show_thread_names = 1;
        highlight_base_name = 1;
        sort_key = 47; # PERCENT_MEM
        left_meters_modes = [
          1
          1
          1
        ];
        left_meters = [
          "AllCPUs"
          "Memory"
          "Swap"
        ];
        right_meters_modes = [
          2
          2
          2
        ];
        right_meters = [
          "Tasks"
          "LoadAverage"
          "Uptime"
        ];
      };
    };
    iftop.enable = mkDefault true;
    iotop.enable = mkDefault true;
    less.lessopen = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    mosh.enable = mkDefault true;
    mtr.enable = mkDefault true;
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
    thunderbird = {
      enable = true;
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
  # Shell
  #

  environment.shellAliases =
    let
      ifSudo = lib.mkIf config.security.sudo.enable;
    in
    {
      # nix
      n = "nix";
      np = "n profile";
      ni = "np install";
      nr = "np remove";
      ns = "n search --no-update-lock-file";
      nf = "n flake";
      nepl = "n repl '<nixpkgs>'";
      srch = "ns nixos";
      orch = "ns override";
      nrb = ifSudo "sudo nixos-rebuild";

      # sudo
      s = ifSudo "sudo -E ";
      si = ifSudo "sudo -i";
      se = ifSudo "sudoedit";

      # systemd
      ctl = "systemctl";
      stl = ifSudo "s systemctl";
      utl = "systemctl --user";
      ut = "systemctl --user start";
      un = "systemctl --user stop";
      up = ifSudo "s systemctl start";
      dn = ifSudo "s systemctl stop";
      jtl = "journalctl";
    };

  users.defaultUserShell = pkgs.fish;

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
    gvfs.enable = true;

    nscd.enableNsncd = true;

    openssh = {
      startWhenNeeded = mkDefault true;
    };

    timesyncd.servers = mkDefault [ "time.cloudflare.com" ];
  };

  #
  # Security
  #

  security = {
    polkit.extraConfig = ''
      /* Allow users in wheel group to manage systemd units without authentication */
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';

    protectKernelImage = mkDefault true;

    sudo.extraConfig = ''
      Defaults timestamp_type=global,timestamp_timeout=600
    '';
  };

  #
  # Locales
  #

  console = {
    font = mkDefault "latarcyrheb-sun16";
    keyMap = mkDefault "us";
  };

  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
    supportedLocales = mkDefault [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  services.xserver.xkb.layout = "us,ru";

  time.timeZone = mkDefault "Europe/Moscow";

  #
  # Misc
  #
  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  environment.variables = {
    PLASMA_USE_QT_SCALING = "1";
  };

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

  services = {
    # tailscale.enable = true;
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
      nix-daemon.serviceConfig.LimitSTACKSoft = "infinity";
      systemd-networkd = {
        serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
      };
    };
    # services.NetworkManager-wait-online.enable = false;
    timers = {
      nix-gc.timerConfig.Persistent = mkDefault true;
      nix-optimise.timerConfig.Persistent = mkDefault true;
    };
  };

  environment.etc."amnezia/amneziawg/home.conf".source = config.sops.secrets.amneziawg-home-conf.path;
}
