{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    electrum
    framesh
    ledger-live-desktop
  ];
  hardware.ledger.enable = true;
  users.groups.plugdev = { };
}
