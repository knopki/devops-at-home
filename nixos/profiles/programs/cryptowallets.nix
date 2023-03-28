{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ framesh ledger-live-desktop trezor-suite ];
  hardware.ledger.enable = true;
  services.trezord.enable = true;
  users.groups.plugdev = { };
}
