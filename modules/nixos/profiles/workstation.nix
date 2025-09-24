#
# Workstation
#
{ lib, self, ... }:
{
  imports = with self.modules.nixos; [
    profile-common
    mixin-pipewire
    programs-helix
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
