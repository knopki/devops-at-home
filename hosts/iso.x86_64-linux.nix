{ modulesPath, pkgs, self, ... }@args:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  knopki.users = {
    root.enable = true;
    nixos.enable = true;
  };
  networking.networkmanager.enable = true;
}
