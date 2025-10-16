{ config, ... }:
let
  commonBackupOpts = {
    user = config.users.users.sk.name;
    createWrapper = true;

    timerConfig.Persistent = true;
    inhibitsSleep = true;
  };
in
{
  services.restic.backups = {
    content = commonBackupOpts // {
      timerConfig.OnCalendar = "weekly";

      repository = "rclone:backupman:/backups/restic-content";
      rcloneOptions = {
        bwlimit = "10M";
      };
      rcloneConfigFile = config.sops.secrets.restic-backupman-content-rclone-config.path;
      passwordFile = config.sops.secrets.restic-backupman-content-repo-password.path;
      initialize = true;

      paths = [ ];

      extraBackupArgs = [
        "--cleanup-cache"
        "--exclude-caches"
        "--ignore-file .resticignore"
        "--pack-size=128"
        "--no-scan"
        "--ignore-inode"
      ];
      checkOpts = [
        "--with-cache"
      ];
      pruneOpts = [
        "--keep-within-dayly 7d"
        "--keep-within-weekly 1m"
        "--keep-within-monthly 1y"
        "--keep-within-yearly 10y"
      ];
    };

  };

  sops.secrets = {
    restic-backupman-content-rclone-config.owner = config.users.users.sk.name;
    restic-backupman-content-repo-password.owner = config.users.users.sk.name;
  };
}
