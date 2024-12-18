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
    iputils
    lsof
    neovim
    ngrep
    pstree
    ranger
    ripgrep
    rmlint
    rsync
    sysstat
    tree
    wget
    whois

    # downloaders
    yt-dlp

    # image-viewers
    imgcat

    # office
    packages.anytype
    aspellDicts.en
    aspellDicts.ru
    gscan2pdf
    img2pdf
    isync
    libsForQt5.ark
    libsForQt5.gwenview
    libsForQt5.okular
    nextcloud-client
    ocrmypdf
    offlineimap
    pdfarranger
    poppler_utils
    qpdf
    rclone
    seahorse
    libsForQt5.kleopatra
    # kdePackages.kleopatra
    speedcrunch
    syncthing
    telegram-desktop
    thunderbird
    xfce.orage
    zotero

    # remote
    anydesk
    mosh
    openssh

    # misc
    android-udev-rules
    clevis
    tailscale
    xorg.xhost
    restic
    rustic-rs
    smartmontools
    yubikey-manager
    vmtouch
    mkchromecast
  ];

  programs = {
    command-not-found.enable = mkDefault false;
    fish.enable = mkDefault true;
    iftop.enable = mkDefault true;
    iotop.enable = mkDefault true;
    mosh.enable = mkDefault true;
    mtr.enable = mkDefault true;
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

      # fix nixos-option
      nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";

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
      trusted-users = mkDefault [
        "root"
      ];
    };
    extraOptions =
      let
        gb = 1024 * 1024 * 1024;
      in
      mkBefore ''
        min-free = ${toString (gb * 10)}
        max-free = ${toString (gb * 20)}
        tarball-ttl = ${toString (86400 * 30)}
      '';
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
    hosts = {
      "127.0.0.84" = [
        "adminer.xod.loc"
        "api.xod.loc"
        "auth.xod.loc"
        "billing-db.xod.loc"
        "billing.xod.loc"
        "compile.xod.loc"
        "compiler.xod.loc"
        "mail.xod.loc"
        "main-db.xod.loc"
        "mqtt.xod.loc"
        "neo4j.xod.loc"
        "pm.xod.loc"
        "releases.xod.loc"
        "rethinkdb.xod.loc"
        "s3.xod.loc"
        "swagger-ui.xod.loc"
        "xod.loc"
      ];
    };
    networkmanager.unmanaged = [ "docker0" ];
    search = [
      "1984.run"
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
    tailscale.enable = true;
  };

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
}
