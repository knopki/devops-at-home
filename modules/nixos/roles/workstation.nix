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
    program-applists
    misc-common-mixin
    service-cosmic-de
    service-pipewire
    program-helix
  ];

  options.roles.workstation.enable = mkEnableOption "Workstation role";

  config = mkIf cfg.enable {
    custom.applists = {
      enable = mkDefault true;
      cliTools = mkDefault true;
      edu = mkDefault true;
      hardware = mkDefault true;
      networking = mkDefault true;
      media = mkDefault true;
      office = mkDefault true;
    };
    custom.cosmic-de.enable = true;
    custom.locale.flavor = mkDefault "en_RU_alt";
    custom.nix.nh.enable = true;
    custom.pipewire.enable = true;

    nix.daemonCPUSchedPolicy = "idle";
    systemd.services.nix-gc.serviceConfig.CPUSchedulingPolicy = "idle";

    nixpkgs.overlays = with self.overlays; [
      my-packages
      nixpkgs-unstable
      unstable-backports
      mpv
    ];

    hardware.ledger.enable = true;

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        corefonts
        nerd-fonts.fira-code
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ];
    };

    programs.bat.enable = true;

    custom.helix = {
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
