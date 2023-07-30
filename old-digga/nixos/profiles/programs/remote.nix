{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mosh
    openssh
    rustdesk
  ];

  services.teamviewer.enable = true;
}
