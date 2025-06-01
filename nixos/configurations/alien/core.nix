{
  config,
  lib,
  pkgs,
  self,
  packages,
  ...
}:
let
  inherit (lib) mkBefore mkDefault;
  mediaPkgs = with pkgs; [
    darktable
    digikam
    imgcat
    inkscape
    kdePackages.kdenlive
    krita
    obs-studio
    picard
    qbittorrent
    streamrip
    upscaler
    upscayl
    yt-dlp
    gallery-dl
    fclones
    packages.findimagedupes
  ];
  officePkgs = with pkgs; [
    anki
    packages.anytype
    packages.aliza
    aspellDicts.en
    aspellDicts.ru
    img2pdf
    isync
    kdePackages.kleopatra
    nextcloud-client
    obsidian
    ocrmypdf
    offlineimap
    onlyoffice-desktopeditors
    pdfarranger
    poppler_utils
    qpdf
    rclone
    seahorse
    speedcrunch
    zotero
  ];
  devPkgs = with pkgs; [
    # tools
    gitMinimal
    gnupg
    ripgrep
    android-udev-rules
    arduino-cli
    lazygit
    picotool
    python3

    # editors / IDE
    arduino-ide
    helix
    packages.zed-editor
    packages.aider-chat

    # bash
    shellcheck

    # javascript
    nodejs

    # python
    uv
  ];
in
{
  #
  # Documentation
  #

  documentation = {
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
    man.enable = mkDefault true;
    nixos.enable = mkDefault false;
  };

  #
  # Packages
  #

  environment.systemPackages =
    with pkgs;
    [
      # essentials
      binutils
      curl
      dnsutils
      dosfstools
      du-dust
      fd
      file
      gitMinimal
      gnupg
      gptfdisk
      helix
      iputils
      lsof
      neovim
      ngrep
      pstree
      ranger
      ripgrep
      rsync
      sysstat
      tree
      wget

      # shell
      atuin
      fishPlugins.fish-you-should-use
      fishPlugins.forgit

      # messenging
      simplex-chat-desktop
      telegram-desktop
      discord
      thunderbird

      # remote
      anydesk
      mosh
      openssh
      remmina

      # misc
      tor-browser
      amneziawg-go
      packages.amneziawg-tools
      bottles
      clevis
      golden-cheetah-bin
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

      # temporary
      usbimager
    ]
    ++ devPkgs
    ++ mediaPkgs
    ++ officePkgs;

  programs = {
    bash = {
      undistractMe.enable = true;
      interactiveShellInit = ''
        if [[ -f $XDG_CONFIG_HOME/atuin/config.toml ]]; then
          eval $(${pkgs.atuin}/bin/atuin init bash)
        fi
      '';
    };
    command-not-found.enable = mkDefault false;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
        source ${packages.ls-colors}/lscolors.csh
        if test -f $XDG_CONFIG_HOME/atuin/config.toml;
          ${pkgs.atuin}/bin/atuin init fish --disable-up-arrow | source
        end
      '';
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
    mosh.enable = mkDefault true;
    mtr.enable = mkDefault true;
    nix-index.enable = mkDefault true;
    nix-ld = {
      enable = mkDefault true;
      libraries = [
        # already included:
        #   acl attr bzip2 curl libsodium libssh libxml2 openssl
        #   stdenv.cc.cc systemd util-linux xz zlib zstd
      ];
    };
    starship = {
      enable = true;
      presets = [ "nerd-font-symbols" ];
      settings = {
        directory = {
          truncation_length = 2;
          fish_style_pwd_dir_length = 2;
        };
      };
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
    channel.enable = false;
    daemonCPUSchedPolicy = mkDefault "idle";
    daemonIOSchedPriority = mkDefault 7;
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-then 30d";
    };
    optimise.automatic = mkDefault true;
    settings = {
      inherit (self.nixConfig) experimental-features extra-substituters extra-trusted-public-keys;
      allowed-users = mkDefault [ "@wheel" ];
      auto-optimise-store = mkDefault true;
    };
    extraOptions =
      let
        gb = 1024 * 1024 * 1024;
      in
      mkBefore ''
        min-free = ${toString (gb * 10)}
        max-free = ${toString (gb * 20)}
        tarball-ttl = ${toString (86400 * 30)}
        !include ${config.sops.templates."nix-access-tokens.conf".path}
      '';
    registry.self.to = {
      type = "path";
      path = self.outPath;
    };
  };

  #
  # Network
  #

  services = {
    envfs.enable = true;

    nscd.enableNsncd = true;

    openssh = {
      enable = mkDefault true;
      startWhenNeeded = mkDefault true;
      settings = {
        PasswordAuthentication = mkDefault false;
      };
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

  meta.suites.workstation = true;
  meta.suites.devbox = true;
  meta.suites.mobile = true;
  meta.suites.gamestation = true;

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
