#
# Workstation role
#
{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.roles.workstation;
in
{
  imports = with self.modules.nixos; [
    profile-applists
    profile-common
    profile-cosmic-de
    profile-pipewire
    profile-terminfo
    program-helix
  ];

  options.roles.workstation.enable = mkEnableOption "Workstation role";

  config = mkIf cfg.enable {
    profiles.applists = {
      enable = mkDefault true;
      cliTools = mkDefault true;
      edu = mkDefault true;
      hardware = mkDefault true;
      networking = mkDefault true;
      media = mkDefault true;
      office = mkDefault true;
    };
    profiles.cosmic-de.enable = true;
    profiles.locale.flavor = mkDefault "en_RU_alt";
    profiles.nix.nh.enable = true;
    profiles.pipewire.enable = true;
    profiles.terminfo.enable = true;

    nix.daemonCPUSchedPolicy = "idle";
    systemd.services.nix-gc.serviceConfig.CPUSchedulingPolicy = "idle";

    nixpkgs.overlays = with self.overlays; [
      my-packages
      nixpkgs-unstable
      unstable-backports
      mpv
    ];

    hardware.ledger.enable = true;

    programs.bat.enable = true;

    programs.helix = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      extraPackagesBash = true;
      extraPackagesGit = true;
      extraPackagesJson = true;
      extraPackagesMarkdown = true;
    };

    services = {
      # Enable SSH everywhere
      openssh = {
        enable = true;
        startWhenNeeded = lib.mkDefault true;
      };
    };

    time.timeZone = mkDefault "Europe/Moscow";
  };
}
