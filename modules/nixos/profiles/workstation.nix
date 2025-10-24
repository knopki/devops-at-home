#
# Workstation
#
{
  lib,
  self,
  pkgs,
  ...
}:
{
  imports = with self.modules.nixos; [
    profile-common
    mixin-cosmic-de
    mixin-pipewire
    programs-helix
  ];

  environment.systemPackages = with pkgs; [
    qalculate-gtk
  ];

  nix.daemonCPUSchedPolicy = "idle";
  systemd.services.nix-gc.serviceConfig.CPUSchedulingPolicy = "idle";

  nixpkgs.overlays = with self.overlays; [
    my-packages
    nixpkgs-unstable
    unstable-backports
  ];

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
  };

  services = {
    # Enable SSH everywhere
    openssh = {
      enable = true;
      startWhenNeeded = lib.mkDefault true;
    };
  };
}
