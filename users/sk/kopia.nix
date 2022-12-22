{ config, lib, pkgs, nixosConfig, ... }:
let inherit (lib) mkIf hm elem; in
{
  home.activation.kopiaSettings =
    let
      lsCmd = "$DRY_RUN_CMD ${pkgs.coreutils}/bin/ln $VERBOSE_ARG -sf";
      secrets = nixosConfig.sops.secrets;
      dst = "${config.xdg.configHome}/kopia";
    in
    hm.dag.entryAfter [ "writeBoundary" ] ''
      ${lsCmd} "${secrets.kopia-repository-config.path}" \
        "${dst}/repository.config"
      ${lsCmd} "${secrets.kopia-knopki-repo-password-file.path}" \
        "${dst}/repository.config.kopia-password"
    '';

  services.kopia = {
    enable = elem nixosConfig.networking.hostName [ "alien" ];
    env = {
      KOPIA_LOG_DIR_MAX_AGE = "168h";
      KOPIA_CONTENT_LOG_DIR_MAX_AGE = "168h";
    };
    jobs = {
      alien-logseq = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "*:0/10"; RandomizedDelaySec = "5m"; };
        snapshots = [
          "${config.home.homeDirectory}/.logseq"
          "${config.home.homeDirectory}/org"
          "${config.xdg.configHome}/Logseq/Preferences"
          "${config.xdg.configHome}/Logseq/configs.edn"
          "${config.xdg.userDirs.documents}/personal"
        ];
      };
      alien-devs = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "*:0/10"; RandomizedDelaySec = "5m"; };
        snapshots = [
          "${config.home.homeDirectory}/dev"
        ];
      };
      alien-browsers = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "daily"; RandomizedDelaySec = "12h"; };
        snapshots = [
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Default"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 1"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 2"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 3"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 4"
        ];
      };
      alien-secrets = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "hourly"; RandomizedDelaySec = "30m"; };
        snapshots = [
          "${config.home.homeDirectory}/.gnupg"
          "${config.home.homeDirectory}/.kube/config"
          "${config.home.homeDirectory}/.var/app/com.bitwarden.desktop/config/Bitwarden CLI/data.json"
          "${config.home.homeDirectory}/.var/app/com.bitwarden.desktop/config/Bitwarden/data.json"
          "${config.home.homeDirectory}/.var/app/org.remmina.Remmina/config/remmina"
          "${config.home.homeDirectory}/.var/app/org.remmina.Remmina/data/remmina"
          "${config.xdg.configHome}/cachix"
          "${config.xdg.configHome}/gcloud"
          "${config.xdg.configHome}/teamviewer"
          "${config.xdg.dataHome}/fish/fish_history"
          "${config.xdg.dataHome}/keyrings"
          "${config.xdg.dataHome}/password-store"
        ];
      };
      alien-docs = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "daily"; RandomizedDelaySec = "12h"; };
        snapshots = [
          "${config.home.homeDirectory}/library"
          "${config.home.homeDirectory}/trash"
          config.xdg.userDirs.desktop
          config.xdg.userDirs.documents
        ];
      };
      alien-media = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "daily"; RandomizedDelaySec = "12h"; };
        snapshots = [
          "${config.home.homeDirectory}/.var/app/org.darktable.Darktable/config/darktable"
          config.xdg.userDirs.videos
          config.xdg.userDirs.music
          config.xdg.userDirs.pictures
        ];
      };
      alien-anki = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "weekly"; RandomizedDelaySec = "24h"; };
        snapshots = [
          "${config.home.homeDirectory}/.var/app/net.ankiweb.Anki/data"
        ];
      };
      alien-random-conf = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = { OnCalendar = "daily"; RandomizedDelaySec = "12h"; };
        snapshots = [
          "${config.home.homeDirectory}/.var/app/org.musicbrainz.Picard/config/MusicBrainz"
          "${config.xdg.configHome}/dconf/user"
        ];
      };
    };
  };
}
