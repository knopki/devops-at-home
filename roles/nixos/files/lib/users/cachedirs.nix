{ config, lib, username, ...}:
let
  selfHM = config.home-manager.users."${username}";
  tag = "Signature: 8a477f597d28d172789f06886806bc55\n";
in with builtins;
{
  home.file = lib.mkMerge (
    map (x: {
      "${x}/CACHEDIR.TAG".text = tag;
    }) [
      "${selfHM.xdg.dataHome}/containers"
      "${selfHM.xdg.dataHome}/flatpak"
      "${selfHM.xdg.dataHome}/npm"
      "${selfHM.xdg.dataHome}/tmux"
      "${selfHM.xdg.dataHome}/Trash"
      "${selfHM.xdg.dataHome}/vim"
      "${selfHM.xdg.configHome}"
      "${selfHM.xdg.configHome}/chromium"
      "${selfHM.xdg.configHome}/Code/Backups"
      "${selfHM.xdg.configHome}/Code/Cache"
      "${selfHM.xdg.configHome}/Code/CachedData"
      "${selfHM.xdg.configHome}/Code/CachedExtensions"
      "${selfHM.xdg.configHome}/Code/GPUCache"
      "${selfHM.xdg.configHome}/Code/logs"
      "${selfHM.xdg.configHome}/epiphany/gsb-threats.db-journalnfig"
      "${selfHM.xdg.configHome}/Marvin"
      "${selfHM.xdg.configHome}/simpleos"
      ".kube/http-cache"
      ".minikube"
      ".mozilla/firefox/Crash Reports"
      ".node-gyp"
      ".var/app/com.skype.Client"
      ".var/app/com.transmissionbt.Transmission"
      ".var/app/com.valvesoftware.Steam"
      ".var/app/im.riot.Riot"
      ".var/app/io.github.GnomeMpv"
      ".var/app/io.github.mujx.Nheko"
      ".var/app/net.ankiweb.Anki"
      ".var/app/org.blender.Blender"
      ".var/app/org.darktable.Darktable/cache"
      ".var/app/org.gimp.GIMP/cache"
      ".var/app/org.gnome.eog"
      ".var/app/org.gnome.Evince"
      ".var/app/org.gnome.Rhythmbox3/cache"
      ".var/app/org.kde.kdeconnect/cache"
      ".var/app/org.kde.krita/cache"
      ".var/app/org.libreoffice.LibreOffice/cache"
      ".var/app/org.musicbrainz.Picard/cache"
      ".var/app/org.nextcloud.Nextcloud/cache"
      ".var/app/org.telegram.desktop"
      "downloads"
      # "xod/__packages__"
    ]
  );
}
