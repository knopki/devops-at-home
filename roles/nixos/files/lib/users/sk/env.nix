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
    # CLUTTER_BACKEND = "wayland";
    # GDK_BACKEND = "wayland";
    BROWSER = "firefox";
    CCACHE_DIR = "${selfHM.xdg.cacheHome}/ccache";
    CUDA_CACHE_PATH = "${selfHM.xdg.cacheHome}/nv";
    ECORE_EVAS_ENGINE = "wayland_egl";
    EDITOR = "vim";
    ELM_ENGINE = "wayland_egl";
    GTK_RC_FILES = "${selfHM.xdg.configHome}/gtk-1.0/gtkrc";
    GTK2_RC_FILES = "${selfHM.xdg.configHome}/gtk-2.0/gtkrc";
    PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    PATH = "${selfHM.home.homeDirectory}/.local/bin:${selfHM.home.homeDirectory}/.local/npm/bin:${selfHM.xdg.dataHome}/flatpak/exports/bin:/var/lib/flatpak/exports/bin:\${PATH}";
    QT_QPA_PLATFORM = "wayland-egl";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-\${XDG_RUNTIME_DIR}/keyring/ssh}";
    TERMINAL = "termite";
    VISUAL = "vim";
    XDG_CURRENT_DESKTOP = "GNOME";
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
  };
}
