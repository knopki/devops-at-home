{
  config,
  lib,
  pkgs,
  self,
  packages,
  ...
}:
let
  inherit (lib) mkBefore mkDefault mkIf;
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

  environment.systemPackages = with pkgs; [
    # essentials
    binutils
    curl
    dnsutils
    dosfstools
    du-dust
    fd
    fdupes
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
    whois

    # media
    darktable
    digikam
    imgcat
    inkscape
    kdePackages.kdenlive
    krita
    obs-studio
    packages.deezer-desktop
    picard
    qbittorrent
    streamrip
    upscaler
    upscayl
    yt-dlp

    # office
    anki
    packages.anytype
    packages.aliza
    aspellDicts.en
    aspellDicts.ru
    img2pdf
    isync
    libreoffice-qt6
    nextcloud-client
    obsidian
    ocrmypdf
    offlineimap
    pdfarranger
    poppler_utils
    qpdf
    rclone
    seahorse
    kdePackages.kleopatra
    speedcrunch
    simplex-chat-desktop
    syncthing
    telegram-desktop
    (discord.override { withOpenASAR = true; })
    thunderbird
    zotero
    tor-browser
    zed-editor

    # remote
    anydesk
    mosh
    openssh
    remmina

    # misc
    amneziawg-go
    arduino-cli
    arduino-ide
    packages.amneziawg-tools
    android-udev-rules
    bottles
    clevis
    golden-cheetah-bin
    fclones
    # tailscale
    xorg.xhost
    picotool
    restic
    rustic-rs
    smartmontools
    yubikey-manager
    vmtouch
  ];

  programs = {
    command-not-found.enable = mkDefault false;
    fish.enable = mkDefault true;
    iftop.enable = mkDefault true;
    iotop.enable = mkDefault true;
    mosh.enable = mkDefault true;
    mtr.enable = mkDefault true;
    nix-index.enable = mkDefault true;
    nix-ld = {
      enable = mkDefault true;
      libraries = with pkgs; [
        # already included:
        #   acl attr bzip2 curl libsodium libssh libxml2 openssl
        #   stdenv.cc.cc systemd util-linux xz zlib zstd
      ];
    };
    tmux.enable = mkDefault true;
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
      allowedTCPPorts = [
        5000 # cast
        7513 # spacemesh
        22000 # syncthing
      ];
      allowedTCPPortRanges = [
        {
          from = 6881;
          to = 6889;
        } # torrents
      ];
      allowedUDPPorts = [
        21027 # syncthing local discovery
        22000 # syncthing
      ];
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
