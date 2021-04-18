{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ electrum ledger-live-desktop trezor-suite ];
  hardware.ledger.enable = true;
  services.trezord.enable = true;
  users.groups.plugdev = { };
}
