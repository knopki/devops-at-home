#
# Workstation
#
{
  lib,
  self,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;

  mediaApps = with pkgs; [
    mpv-with-plugins
    swayimg
  ];
  officeSuite = with pkgs; [
    aliza
    anki
    anytype
    citations
    dialect
    gImageReader
    img2pdf
    keepassxc
    khal
    khard
    naps2
    nextcloud-client
    obsidian
    ocrmypdf
    onlyoffice-desktopeditors
    pdfarranger
    telegram-desktop
    qalculate-gtk
    qpdf
    weasis
    zotero
  ];
in
{
  imports = with self.modules.nixos; [
    profile-common
    mixin-cosmic-de
    mixin-locale-white-russian
    mixin-pipewire
    programs-helix
  ];

  environment.systemPackages =
    with pkgs;
    [
      chezmoi
    ]
    ++ mediaApps
    ++ officeSuite;

  nix.daemonCPUSchedPolicy = "idle";
  systemd.services.nix-gc.serviceConfig.CPUSchedulingPolicy = "idle";

  nixpkgs.overlays = with self.overlays; [
    my-packages
    nixpkgs-unstable
    unstable-backports
    mpv
  ];

  hardware = {
    ledger.enable = true;
  };

  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      extraPackagesBash = true;
      extraPackagesGit = true;
      extraPackagesJson = true;
      extraPackagesMarkdown = true;
    };
    thunderbird.enable = true;
  };

  services = {
    # Enable SSH everywhere
    openssh = {
      enable = true;
      startWhenNeeded = lib.mkDefault true;
    };
  };

  time.timeZone = mkDefault "Europe/Moscow";
}
