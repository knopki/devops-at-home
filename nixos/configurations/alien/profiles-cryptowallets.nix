{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    electrum
    framesh
    ledger-live-desktop
    trezor-suite
  ];
  hardware.ledger.enable = true;
  services.trezord.enable = true;
  users.groups.plugdev = { };
}
