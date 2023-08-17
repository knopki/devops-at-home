{config, ...}: {
  home.file = {
    "${config.xdg.configHome}/gtk-3.0/bookmarks".text = ''
      file://${config.home.homeDirectory}/dev Development
      file://${config.home.homeDirectory}/docs Documents
      file://${config.home.homeDirectory}/downloads Downloads
      file://${config.home.homeDirectory}/music Music
      file://${config.home.homeDirectory}/pics Pictures
      file://${config.home.homeDirectory}/videos Videos
      file://${config.home.homeDirectory}/library Library
      file://${config.home.homeDirectory}/trash Trash
    '';
  };
}
