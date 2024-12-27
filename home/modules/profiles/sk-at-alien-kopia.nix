{
  config,
  lib,
  pkgs,
  self,
  inputs,
  ...
}:
{
  imports = with self.modules.homeManager; [ legacy-kopia ];

  sops = {
    secrets = {
      kopia-repository-config = { };
      kopia-knopki-repo-password-env-file = { };
    };
  };

  services.kopia = {
    enable = true;
    env = {
      KOPIA_LOG_DIR_MAX_AGE = "168h";
      KOPIA_CONTENT_LOG_DIR_MAX_AGE = "168h";
      KOPIA_CONFIG_PATH = config.sops.secrets.kopia-repository-config.path;
    };
    envFile = config.sops.secrets.kopia-knopki-repo-password-env-file.path;
    jobs = {
      alien-anytype = {
        timer = {
          OnCalendar = "daily";
          RandomizedDelaySec = "12h";
        };
        snapshots = [ "${config.xdg.dataHome}/anytype" ];
      };
      alien-devs = {
        timer = {
          OnCalendar = "hourly";
          RandomizedDelaySec = "5m";
        };
        snapshots = [ "${config.home.homeDirectory}/dev" ];
      };
      alien-browsers = {
        timer = {
          OnCalendar = "daily";
          RandomizedDelaySec = "12h";
        };
        snapshots = [
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Default"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 1"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 2"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 3"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 4"
        ];
      };
      alien-secrets = {
        timer = {
          OnCalendar = "hourly";
          RandomizedDelaySec = "30m";
        };
        snapshots = [
          "${config.home.homeDirectory}/.gnupg"
          "${config.home.homeDirectory}/.kube/config"
          "${config.home.homeDirectory}/secrets"
          "${config.xdg.configHome}/cachix"
          "${config.xdg.configHome}/gcloud"
          "${config.xdg.configHome}/remmina"
          "${config.xdg.configHome}/sops/age"
          "${config.xdg.dataHome}/fish/fish_history"
          "${config.xdg.dataHome}/keyrings"
          "${config.xdg.dataHome}/password-store"
          "${config.xdg.dataHome}/remmina"
        ];
      };
      alien-electrum = {
        timer = {
          OnCalendar = "daily";
          RandomizedDelaySec = "12h";
        };
        snapshots = [ "${config.home.homeDirectory}/.electrum" ];
      };
      alien-docs = {
        timer = {
          OnCalendar = "hourly";
          RandomizedDelaySec = "5m";
        };
        snapshots = [
          "${config.home.homeDirectory}/.zotero"
          "${config.home.homeDirectory}/library"
          "${config.home.homeDirectory}/trash"
          "${config.xdg.dataHome}/Zotero"
          config.xdg.userDirs.desktop
          config.xdg.userDirs.documents
        ];
      };
      alien-media = {
        timer = {
          OnCalendar = "daily";
          RandomizedDelaySec = "12h";
        };
        snapshots = [
          "${config.xdg.configHome}/darktable"
          config.xdg.userDirs.videos
          config.xdg.userDirs.music
          config.xdg.userDirs.pictures
        ];
      };
      alien-anki = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        snapshots = [
          "${config.xdg.dataHome}/Anki"
          "${config.xdg.dataHome}/Anki2"
        ];
      };
      alien-random-conf = {
        timer = {
          OnCalendar = "daily";
          RandomizedDelaySec = "12h";
        };
        snapshots = [
          "${config.xdg.configHome}/MusicBrainz"
          "${config.xdg.configHome}/dconf/user"
          "${config.xdg.configHome}/obsidian/Custom Dictionary.txt"
          "${config.xdg.configHome}/obsidian/Custom Dictionary.txt"
          "${config.xdg.configHome}/obsidian/Preferences"
          "${config.xdg.configHome}/obsidian/obsidian.json"
          "${config.xdg.configHome}/rclone"
          "${config.xdg.configHome}/syncthing"
          "${config.xdg.configHome}/syncthingtray.ini"
        ];
      };
      alien-dev-archive = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        args = [ "--override-source=${config.home.homeDirectory}/dev/archive" ];
        snapshots = [ "${config.home.homeDirectory}/remote/sk-nc/Dev/Archive" ];
      };
      alien-library = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        args = [ "--override-source=${config.home.homeDirectory}/library" ];
        snapshots = [ "${config.home.homeDirectory}/remote/sk-nc/Family Library" ];
      };
      alien-music = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        args = [ "--override-source=${config.home.homeDirectory}/music" ];
        snapshots = [ "${config.home.homeDirectory}/remote/sk-nc/Family Music" ];
      };
      alien-photos = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        args = [ "--override-source=${config.home.homeDirectory}/pics/photos" ];
        snapshots = [ "${config.home.homeDirectory}/remote/sk-nc/Family Photos" ];
      };
      alien-pics-mobile = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        args = [ "--override-source=${config.home.homeDirectory}/pics/mobile" ];
        snapshots = [ "${config.home.homeDirectory}/remote/sk-nc/Pics/Mobile" ];
      };
      alien-photos-unsorted = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        args = [ "--override-source=${config.home.homeDirectory}/pics/photos-unsorted" ];
        snapshots = [ "${config.home.homeDirectory}/remote/sk-nc/Pics/Photos Unsorted" ];
      };
      alien-photos-raws = {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "24h";
        };
        args = [ "--override-source=${config.home.homeDirectory}/pics/raws" ];
        snapshots = [ "${config.home.homeDirectory}/remote/sk-nc/Pics/RAWs" ];
      };
      alien-mail = {
        timer = {
          OnCalendar = "daily";
          RandomizedDelaySec = "12h";
        };
        snapshots = [
          "${config.home.homeDirectory}/.thunderbird"
          "${config.xdg.dataHome}/calendars"
          "${config.xdg.dataHome}/contacts"
        ];
      };
    };
  };
}
