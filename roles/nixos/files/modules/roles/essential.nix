{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.essential.enable = mkEnableOption "Essential Role";
  };

  config = mkIf config.local.roles.essential.enable {
    local.general.nix.enable = true;
    local.general.nixpkgs.enable = true;
    local.general.security.enable = true;
    local.general.system.enable = true;

    # common packages on all machines
    environment.systemPackages = with pkgs; [
      bat
      curl
      fd
      file
      fish
      fish-foreign-env
      fish-theme-pure
      fzf
      gnupg
      htop
      iftop
      iotop
      jq
      pinentry
      pinentry_ncurses
      pstree
      python3 # required by ansible
      ripgrep
      rsync
      sysstat
      wget
    ];
  };
}
