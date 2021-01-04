{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.zathura.enable = mkEnableOption "enable zathura configuration";

  config = mkIf config.knopki.zathura.enable {
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        font = "Noto Sans 10";
      };
    };

    xdg.mimeApps = {
      associations.added = {
        "application/epub+zip" = ["org.pwmt.zathura.desktop"];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
      };
    };
  };
}
