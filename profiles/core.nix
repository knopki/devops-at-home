# this profile is always applied
{ config, lib, pkgs, ... }:
with lib;
{
  boot = {
    rebootOnPanicOrOOM = true;
    tmpOnTmpfs = true;
  };

  console = {
    font = mkDefault "latarcyrheb-sun16";
    keyMap = mkDefault "us";
  };

  # common packages on all machines (very opionated)
  # merged with `requiredPackages' from
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/system-path.nix
  environment.systemPackages = with pkgs; [
    bind
    binutils
    curl
    fd
    file
    gitMinimal
    gnupg
    hdparm
    htop
    lm_sensors
    lsof
    neovim
    ngrep
    pciutils
    pstree
    ranger
    ripgrep
    rsync
    sysstat
    tree
    unrar
    unzip
    usbutils
    wget
  ];

  hardware.enableRedistributableFirmware = mkDefault true;

  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
    supportedLocales = mkDefault [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  };

  networking = {
    firewall = {
      rejectPackets = true;
    };
  };


  nix = {
    allowedUsers = [ "@wheel" ];
    autoOptimiseStore = mkDefault true;
    extraOptions =
      let
        gcMinFree = 10 * 1024 * 1024 * 1024;
      in
      mkBefore ''
        # flakes support
        experimental-features = nix-command flakes ca-references

        # GC
        min-free = ${toString gcMinFree}
        max-free = ${toString (gcMinFree * 2)}
        tarball-ttl = ${toString (86400 * 30)}
      '';
    daemonIONiceLevel = mkDefault 7;
    daemonNiceLevel = mkDefault 19;
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-then 30d";
    };
    nixPath =
      let
        rebuild-throw = pkgs.writeText "rebuild-throw.nix"
          ''throw "I'm sorry Dave, I'm afraid I can't do that... Please, use flakes."'';
      in
      [
        "nixpkgs=${config.nix.registry.nixpkgs.flake}"
        "nixos-config=${rebuild-throw}"
      ];
    optimise.automatic = mkDefault true;
    package = pkgs.nixFlakes;
    trustedUsers = [ "root" "@wheel" ];
  };

  programs = {
    command-not-found.enable = mkDefault false;
    fish.enable = mkDefault true;
    iftop.enable = mkDefault true;
    iotop.enable = mkDefault true;
    mosh.enable = mkDefault true;
    mtr.enable = mkDefault true;
    tmux.enable = mkDefault true;
  };

  time.timeZone = mkDefault "Europe/Moscow";

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

    sudo.extraRules = [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild switch";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  services = {
    dbus.socketActivated = mkDefault true;

    openssh = {
      enable = mkDefault true;
      passwordAuthentication = mkDefault false;
      startWhenNeeded = mkDefault true;
    };

    timesyncd.servers = mkDefault [ "time.cloudflare.com" ];
  };

  sops.defaultSopsFile = ../secrets/secrets.yaml;

  # Dereference symlinks to /run/secrets, so users.users.<name>.passwordFile is usable
  system.activationScripts.setup-secrets-persist = stringAfter [ "setup-secrets" ] ''
    echo persisting secrets...
    install -m 0750 -d /var/secrets
    chown root:keys /var/secrets
    find /var/secrets -type l -exec ${pkgs.bash}/bin/sh -c 'cp --remove-destination $(readlink "{}") "{}"' \;
  '';

  systemd.services.nix-daemon.serviceConfig.LimitSTACKSoft = "infinity";

  systemd.timers = {
    nix-gc.timerConfig.Persistent = mkDefault true;
    nix-optimise.timerConfig.Persistent = mkDefault true;
  };

  users.mutableUsers = mkDefault false;
}
