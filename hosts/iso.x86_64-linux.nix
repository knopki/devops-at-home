{ modulesPath, pkgs, self, ... }@args:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    (import ../users/root.nix args)
    (import ../users/nixos.nix args)
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  networking.networkmanager.enable = true;
}
