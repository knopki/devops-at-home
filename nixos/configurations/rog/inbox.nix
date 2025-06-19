# Temporary configuration that should go away
# Remove or move to modules/other files
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mpv
    python3
    vmtouch
    swayimg
    helix
  ];

  i18n.extraLocales = [ "ru_RU.UTF-8/UTF-8" ];

  programs = {
    bat.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  time.timeZone = "Europe/Moscow";
}
