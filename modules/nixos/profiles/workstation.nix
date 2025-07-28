#
# Workstation
#
{ self, ... }:
{
  imports = with self.modules.nixos; [ programs-helix ];

  nixpkgs.overlays = with self.overlays; [
    nixpkgs-unstable
    my-packages
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
}
