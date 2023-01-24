{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ledger-live-desktop trezor-suite ];
  hardware.ledger.enable = true;
  services.trezord.enable = true;
  users.groups.plugdev = { };
}
