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
      alien-daily = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = {
          OnCalendar = "daily";
          RandomizedDelaySec = "3h";
        };
        snapshots = [
          "${config.home.homeDirectory}/.gnupg"
          "${config.home.homeDirectory}/.logseq"
          "${config.home.homeDirectory}/dev"
          "${config.home.homeDirectory}/library"
          "${config.home.homeDirectory}/org"
          "${config.home.homeDirectory}/trash"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Default"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 1"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 2"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 3"
          "${config.xdg.configHome}/BraveSoftware/Brave-Browser/Profile 4"
          "${config.xdg.configHome}/Logseq/configs.edn"
          "${config.xdg.dataHome}/fish/fish_history"
          config.xdg.userDirs.desktop
          config.xdg.userDirs.documents
          config.xdg.userDirs.pictures
        ];
      };

      alien-weekly = mkIf (nixosConfig.networking.hostName == "alien") {
        timer = {
          OnCalendar = "weekly";
          RandomizedDelaySec = "12h";
        };
        snapshots = [
          "${config.home.homeDirectory}/.kube/config"
          "${config.xdg.configHome}/MusicBrainz"
          "${config.xdg.configHome}/cachix"
          "${config.xdg.configHome}/darktable"
          "${config.xdg.configHome}/dconf/user"
          "${config.xdg.configHome}/gcloud"
          "${config.xdg.configHome}/remmina"
          "${config.xdg.configHome}/teamviewer"
          "${config.xdg.dataHome}/Anki2"
          "${config.xdg.dataHome}/keyrings"
          "${config.xdg.dataHome}/password-store"
          config.xdg.userDirs.music
        ];
      };
    };
  };
}
