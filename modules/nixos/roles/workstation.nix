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
    program-fish
    misc-common-mixin
    service-cosmic-de
    service-pipewire
    program-helix
  ];

  options.roles.workstation.enable = mkEnableOption "Workstation role";

  config = mkIf cfg.enable {
    custom = {
      applists = {
        enable = mkDefault true;
        cliTools = mkDefault true;
        edu = mkDefault true;
        hardware = mkDefault true;
        networking = mkDefault true;
        media = mkDefault true;
        office = mkDefault true;
      };
      cosmic-de.enable = true;
      fish = {
        enable = true;
        enableFzf = true;
        enableStarship = true;
      };
      locale.flavor = mkDefault "en_RU_alt";
      nix.nh.enable = true;
      pipewire.enable = true;
    };

    boot.kernelParams = [ "quit" ];
    boot.plymouth.enable = true;

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

    programs = {
      bat.enable = true;

      bash.undistractMe.enable = mkDefault true;

      iftop.enable = mkDefault true;

      vivid = {
        enable = mkDefault true;
        theme = mkDefault "one-dark";
      };
    };

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

    system.tools = {
      nixos-build-vms.enable = mkDefault false;
      nixos-enter.enable = mkDefault false;
      nixos-install.enable = mkDefault false;
      nixos-option.enable = mkDefault false;
      nixos-version.enable = mkDefault false;
    };

    time.timeZone = mkDefault "Europe/Moscow";
  };
}
