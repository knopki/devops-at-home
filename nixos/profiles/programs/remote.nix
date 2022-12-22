{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mosh
    openssh
    teamviewer
  ];

  services.teamviewer.enable = true;
}
