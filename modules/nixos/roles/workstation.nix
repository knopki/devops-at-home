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
    custom.fish = {
      enable = true;
      enableFzf = true;
      enableStarship = true;
    };
    custom.locale.flavor = mkDefault "en_RU_alt";
    custom.nix.nh.enable = true;
    custom.pipewire.enable = true;

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

    programs.bat.enable = true;

    programs.bash.undistractMe.enable = mkDefault true;

    programs.iftop.enable = mkDefault true;

    programs.vivid = {
      enable = mkDefault true;
      theme = mkDefault "one-dark";
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

    system.tools.nixos-build-vms.enable = mkDefault false;
    system.tools.nixos-enter.enable = mkDefault false;
    system.tools.nixos-install.enable = mkDefault false;
    system.tools.nixos-option.enable = mkDefault false;
    system.tools.nixos-version.enable = mkDefault false;

    time.timeZone = mkDefault "Europe/Moscow";
  };
}
