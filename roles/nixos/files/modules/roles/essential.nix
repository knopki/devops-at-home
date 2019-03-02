{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.essential.enable = mkEnableOption "Essential Role";
  };

  config = mkIf config.local.roles.essential.enable {
    local.apps.fish.enable = true;

    local.general.i18n.enable = true;
    local.general.nix.enable = true;
    local.general.nixpkgs.enable = true;
    local.general.security.enable = true;
    local.general.system.enable = true;

    local.services.timesyncd.enable = true;

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
      curl
      fd
      file
      fzf
      gnupg
      htop
      iftop
      iotop
      jq
      nnn
      pinentry
      pinentry_ncurses
      pstree
      python3 # required by ansible
      ranger
      ripgrep
      rsync
      sysstat
      wget
    ];
  };
}
