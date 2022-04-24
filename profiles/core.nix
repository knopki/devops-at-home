{ config, lib, pkgs, self, ... }:
let
  inherit (lib) mkBefore mkDefault mkIf attrNames length stringAfter;
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

  # common packages on all machines (very opionated)
  # merged with `requiredPackages' from
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/system-path.nix
  environment.systemPackages = with pkgs; [
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
  ];

  programs = {
    command-not-found.enable = mkDefault false;
    fish.enable = mkDefault true;
    iftop.enable = mkDefault true;
    iotop.enable = mkDefault true;
    mosh.enable = mkDefault true;
    mtr.enable = mkDefault true;
    tmux.enable = mkDefault true;
  };


  #
  # Shell
  #

  environment.shellAliases =
    let ifSudo = lib.mkIf config.security.sudo.enable;
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
    allowedUsers = mkDefault [ "@wheel" ];
    autoOptimiseStore = mkDefault true;
    binaryCaches = [ "https://cache.nixos.org/" ];
    daemonCPUSchedPolicy = mkDefault "idle";
    daemonIOSchedPriority = mkDefault 7;
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-then 30d";
    };
    optimise.automatic = mkDefault true;
    trustedUsers = mkDefault [ "root" "@wheel" ];
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

  systemd.services.nix-daemon.serviceConfig.LimitSTACKSoft = "infinity";

  systemd.timers = {
    nix-gc.timerConfig.Persistent = mkDefault true;
    nix-optimise.timerConfig.Persistent = mkDefault true;
  };

  #
  # Network
  #

  networking = {
    firewall = {
      rejectPackets = mkDefault true;
    };
  };

  services = {
    openssh = {
      enable = mkDefault true;
      passwordAuthentication = mkDefault false;
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

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
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
    supportedLocales = mkDefault [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  };

  services.xserver.layout = "us,ru";

  time.timeZone = mkDefault "Europe/Moscow";


  #
  # Misc
  #

  systemd.linger.enable = true;

  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';
}
