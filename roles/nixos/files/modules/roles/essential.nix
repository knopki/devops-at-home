{ config, pkgs, lib, ... }:

with lib;

{
  options = { local.roles.essential.enable = mkEnableOption "Essential Role"; };

  config = mkIf config.local.roles.essential.enable {
    local = {
      apps = { fish.enable = true; };

      general = {
        i18n.enable = true;
        nix.enable = true;
        nixpkgs.enable = true;
        security.enable = true;
        system.enable = true;
      };

      services = {
        timesyncd.enable = true;
        ssh.enable = true;
      };

      users.setupUsers = [ "root" ];
    };

    boot.kernel.sysctl = {
      "kernel.panic_on_oops" = 1;
      "kernel.panic" = 20;
      "net.ipv4.ip_nonlocal_bind" = 1;
      "net.ipv6.ip_nonlocal_bind" = 1;
      "vm.panic_on_oom" = 1;
    };

    # common packages on all machines
    environment.systemPackages = with pkgs; [
      bat
      bind
      cachix
      curl
      file
      gitAndTools.gitFull
      gnupg
      htop
      iftop
      iotop
      jq
      lsof
      neovim
      nnn
      pinentry
      pinentry_ncurses
      pstree
      python3 # required by ansible
      ranger
      ripgrep
      rsync
      sysstat
      tree
      usbutils
      wget
    ];

    hardware.enableRedistributableFirmware = true;

    home-manager.useUserPackages = true;

    programs = {
      bash.enableCompletion = true;
      mtr.enable = true;
      tmux.enable = true;
    };

    time.timeZone = "Europe/Moscow";

    services.dbus.socketActivated = true;
  };
}
