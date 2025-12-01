{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    electrum
    framesh
    ledger-live-desktop
  ];
  users.groups.plugdev = { };
}
