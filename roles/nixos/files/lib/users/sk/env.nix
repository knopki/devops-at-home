{ pkgs, config, username, ...}:
let
  selfHM = config.home-manager.users."${username}";
in with builtins;
{
  # TODO: move to separate files
  home.sessionVariables = {
    __GL_SHADER_DISK_CACHE_PATH = "${selfHM.xdg.cacheHome}/nv";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
    BROWSER = "firefox";
    CUDA_CACHE_PATH = "${selfHM.xdg.cacheHome}/nv";
    EDITOR = "vim";
    PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    PATH = "${selfHM.home.homeDirectory}/.local/bin:${selfHM.home.homeDirectory}/.local/npm/bin:${selfHM.xdg.dataHome}/flatpak/exports/bin:/var/lib/flatpak/exports/bin:\${PATH}";
    SDL_VIDEODRIVER = "wayland";
    TERMINAL = "termite";
    VISUAL = "vim";
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    DBUS_SESSION_BUS_ADDRESS = "unix:path=${selfHM.home.sessionVariables.XDG_RUNTIME_DIR}/bus";
  };
}
