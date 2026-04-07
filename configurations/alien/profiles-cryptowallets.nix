{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    electrum
    # framesh # temporary disabled - not used
    ledger-live-desktop
  ];
  users.groups.plugdev = { };
}
