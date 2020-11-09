{ modulesPath, pkgs, self, ... }@args:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    ../users/root.nix
    ../users/nixos.nix
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  networking.networkmanager.enable = true;
}
