{ lib, config, options, ... }:
let
  inherit (lib) mkMerge mkIf nameValuePair listToAttrs;
in
{
  xdg = mkMerge [
    {
      enable = true;
    }

    (mkIf (options ? xdg.mimeApps) {
      configFile."mimeapps.list".force = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/epub+zip" = "org.pwmt.zathura.desktop";
          "application/pdf" = "org.pwmt.zathura.desktop";
        } // (listToAttrs (map (x: nameValuePair x "org.kde.gwenview.desktop") [
          "image/bmp"
          "image/gif"
          "image/jpeg"
          "image/jpg"
          "image/pjpeg"
          "image/png"
          "image/svg+xml"
          "image/svg+xml-compressed"
          "image/tiff"
          "image/vnd.wap.wbmp"
          "image/x-bmp"
          "image/x-gray"
          "image/x-icb"
          "image/x-icns"
          "image/x-ico"
          "image/x-pcx"
          "image/x-png"
          "image/x-portable-anymap"
          "image/x-portable-bitmap"
          "image/x-portable-graymap"
          "image/x-portable-pixmap"
          "image/x-xbitmap"
          "image/x-xpixmap"
        ])) // (listToAttrs (map (x: nameValuePair x "brave-browser.desktop") [
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "application/xhtml+xml"
          "application/xml"
          "text/html"
          "x-scheme-handler/ftp"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/ipfs"
          "x-scheme-handler/ipns"
        ]));
      };
    })

    (mkIf (options ? xdg.userDirs) {
      configFile."user-dirs.locale".text = "en_US";
      configFile."user-dirs.dirs".force = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${config.home.homeDirectory}/desktop";
        documents = "${config.home.homeDirectory}/docs";
        download = "${config.home.homeDirectory}/downloads";
        music = "${config.home.homeDirectory}/music";
        pictures = "${config.home.homeDirectory}/pics";
        publicShare = "${config.home.homeDirectory}/public";
        templates = "${config.home.homeDirectory}/templates";
        videos = "${config.home.homeDirectory}/videos";
      };
    })
  ];
}
