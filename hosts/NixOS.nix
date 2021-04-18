{ suites, ... }:
{
  imports = suites.base ++ [ ../users/nixos ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };

  ### root password is empty by default ###
  users.users.root.password = "";

  system.stateVersion = "21.05";
}
