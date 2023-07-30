{ config, nixosConfig, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.kde.settings.spectaclerc = {
    General = {
      autoSaveImage = true;
      copyImageToClipboard = true;
      copySaveLocation = false;
    };
    Save = {
      defaultSaveLocation = "file://${config.xdg.userDirs.pictures}/screenshots/";
      saveFilenameFormat = "scrn-%Y%M%D-%H%m%S";
    };
  };
}
