{ pkgs, packages, ... }:
{
  environment.systemPackages = with pkgs; [
    framesh
    packages.ledger-live-desktop
    trezor-suite
  ];
  hardware.ledger.enable = true;
  services.trezord.enable = true;
  users.groups.plugdev = { };
}
