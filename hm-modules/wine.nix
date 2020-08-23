{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.wine = {
    enable = mkEnableOption "wine configuration";
  };

  config = mkIf config.knopki.wine.enable {
    xdg.mimeApps = mkIf config.knopki.firefox.mime {
      enable = true;
      associations.removed = {
        "application/pdf" = [ "wine-extension-pdf.desktop" ];
        "application/rtf" = [ "wine-extension-rtf.desktop" ];
        "application/xml" = [ "wine-extension-xml.desktop" ];
        "image/gif" = [ "wine-extension-gif.desktop" ];
        "image/jpeg" = [ "wine-extension-jpe.desktop" "wine-extension-jfif.desktop" ];
        "image/png" = [ "wine-extension-png.desktop" ];
        "text/html" = [ "wine-extension-htm.desktop" ];
        "text/plain" = [ "wine-extension-txt.desktop" ];
      };
    };
  };
}
