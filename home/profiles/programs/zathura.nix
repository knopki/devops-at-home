{ lib, ... }:
{
  programs.zathura = {
    enable = lib.mkDefault true;
    options = {
      selection-clipboard = "clipboard";
    };
  };

  xdg.mimeApps = {
    associations.added = {
      "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
  };
}
