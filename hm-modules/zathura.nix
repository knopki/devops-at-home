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

        # theme base16-darkone
        default-bg = "#282c34";
        default-fg = "#353b45";
        statusbar-fg = "#565c64";
        statusbar-bg = "#3e4451";
        inputbar-bg = "#282c34";
        inputbar-fg = "#c8ccd4";
        notification-bg = "#282c34";
        notification-fg = "#c8ccd4";
        notification-error-bg = "#282c34";
        notification-error-fg = "#e06c75";
        notification-warning-bg = "#282c34";
        notification-warning-fg = "#e06c75";
        highlight-color = "#e5c07b";
        highlight-active-color = "#61afef";
        completion-bg = "#353b45";
        completion-fg = "#61afef";
        completion-highlight-fg = "#c8ccd4";
        completion-highlight-bg = "#61afef";
        recolor-lightcolor = "#282c34";
        recolor-darkcolor = "#b6bdca";
        recolor = "false";
        recolor-keephue = "false";
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
