{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mosh
    openssh
    remmina
    teamviewer
  ];

  services.teamviewer.enable = true;
}
