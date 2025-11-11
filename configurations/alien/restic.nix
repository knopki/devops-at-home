{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) toFile;
  inherit (lib.lists) foldl;
  inherit (lib.modules) mkForce;

  commonResticSopsSecretAttrs = {
    owner = resticUser.name;
    group = config.users.groups.restic-repos.name;
    mode = "0440";
  };

  resticUser = config.users.users.restic;
  superRestic = pkgs.writeShellScriptBin "restic" ''
    exec /run/wrappers/bin/${config.security.wrappers.restic.program} "$@"
  '';

  mkIgnoresFile = xs: toFile "ignore" (foldl (a: b: a + "\n" + b) "" xs);
  generalIgnorePatterns = [
    ".cache"
    "cache"
    ".tmp"
    ".temp"
    "tmp"
    "temp"
    ".log"
    "log"
    ".Trash"
    ".direnv"
    ".venv"
    "/home/*/**/node_modules"
    "/home/*/.cache"
  ];
  electronAppsIgnorePatterns = [
    "/home/*/.config/**/blob_storage"
    "/home/*/.config/**/Application Cache"
    "/home/*/.config/**/Cache"
    "/home/*/.config/**/CachedData"
    "/home/*/.config/**/Code Cache"
    "/home/*/.config/**/GPUCache"
    "/home/*/.var/app/**/blob_storage"
    "/home/*/.var/app/**/Application Cache"
    "/home/*/.var/app/**/Cache"
    "/home/*/.var/app/**/CachedData"
    "/home/*/.var/app/**/Code Cache"
    "/home/*/.var/app/**/GPUCache"
  ];
  homeIgnorePatterns = generalIgnorePatterns ++ electronAppsIgnorePatterns;
  homeIgnoresFile = mkIgnoresFile homeIgnorePatterns;

  commonOpts = {
    user = resticUser.name;
    createWrapper = true;

    timerConfig.Persistent = true;

    extraBackupArgs = [
      "--cleanup-cache"
      "--exclude-caches"
      "--pack-size=128"
      "--ignore-ctime"
      "--ignore-inode"
    ];
  };
  commonBackupsOpts = commonOpts // {
    timerConfig.RandomizedDelaySec = "3h";
    package = superRestic;
    extraBackupArgs = commonOpts.extraBackupArgs ++ [
      "--no-scan"
      "--exclude-file=${homeIgnoresFile}"
      "--exclude-file=${config.users.users.sk.home}/.resticignore"
    ];
  };
  commonMaintenanceOpts = commonOpts // {
    timerConfig.RandomizedDelaySec = "6h";
    checkOpts = [
      "--read-data-subset=128M"
    ];
    pruneOpts = [
      "--keep-within-yearly 10y"
      "--keep-within-monthly 1y"
      "--keep-within-weekly 1m"
      "--keep-within-daily 7d"
      "--keep-within-hourly 1d"
    ];
  };

  contentJobCommon = commonOpts // {
    timerConfig.OnCalendar = "weekly";
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-content-repo.path;
    passwordFile = config.sops.secrets.restic-content-repo-password.path;
  };

  sensitiveJobCommon = commonOpts // {
    timerConfig.OnCalendar = "weekly";
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-sensitive-repo.path;
    passwordFile = config.sops.secrets.restic-sensitive-repo-password.path;
  };

  userDataJobCommon = commonOpts // {
    timerConfig.OnCalendar = "weekly";
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-user-data-repo.path;
    passwordFile = config.sops.secrets.restic-user-data-repo-password.path;
  };

  userMediaJobCommon = commonOpts // {
    timerConfig.OnCalendar = "weekly";
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-user-media-repo.path;
    passwordFile = config.sops.secrets.restic-user-media-repo-password.path;
  };

  systemDataJobCommon = commonOpts // {
    timerConfig.OnCalendar = "weekly";
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-system-data-repo.path;
    passwordFile = config.sops.secrets.restic-system-data-repo-password.path;
  };
in
{
  # restic user
  users.users.restic = {
    isSystemUser = true;
    description = "Restic backup user";
    group = "restic";
  };
  users.groups.restic = { };
  users.groups.restic-remote-domashka.members = [
    config.users.users.restic.name
    config.users.users.sk.name
  ];
  users.groups.restic-repos.members = [
    config.users.users.restic.name
    config.users.users.sk.name
  ];

  # security wrapper that allows restic binary to read
  # any data when running by unpriviledged user
  security.wrappers.restic = {
    source = "${pkgs.restic.out}/bin/restic";
    owner = resticUser.name;
    group = config.users.groups.restic.name;
    permissions = "u=rwx,g=rx,o=";
    capabilities = "cap_dac_read_search=+ep";
  };

  services.restic.backups = {
    content =
      commonBackupsOpts
      // contentJobCommon
      // {
        timerConfig.OnCalendar = "daily";
        paths = (
          map (x: "${config.users.users.sk.home}/${x}") [
            "music"
            "videos"
          ]
        );
      };
    content-maintenance = commonMaintenanceOpts // contentJobCommon;

    sensitive =
      commonBackupsOpts
      // sensitiveJobCommon
      // {
        timerConfig.OnCalendar = "daily";
        paths = map (x: "${config.users.users.sk.home}/${x}") [
          ".config/cachix"
          ".config/gcloud"
          ".config/rclone"
          ".config/sops/age"
          ".electrum"
          ".gnupg"
          ".local/share/atuin"
          ".local/share/fish"
          ".local/share/keyrings"
          "secrets"
        ];
      };
    sensitive-maintenance = commonMaintenanceOpts // sensitiveJobCommon;

    user-data =
      commonBackupsOpts
      // userDataJobCommon
      // {
        timerConfig.OnCalendar = "daily";
        paths = (
          map (x: "${config.users.users.sk.home}/${x}") [
            ".local/share/Zotero"
            ".local/share/calendars"
            ".local/share/contacts"
            "desktop"
            "dev"
            "docs"
            "prj"
            "trash"
          ]
        );
      };
    user-data-maintenance = commonMaintenanceOpts // userDataJobCommon;

    user-media =
      commonBackupsOpts
      // userMediaJobCommon
      // {
        timerConfig.OnCalendar = "daily";
        paths = (
          map (x: "${config.users.users.sk.home}/${x}") [
            "pics"
          ]
        );
      };
    user-media-maintenance = commonMaintenanceOpts // userMediaJobCommon;

    system-data =
      commonBackupsOpts
      // systemDataJobCommon
      // {
        timerConfig.OnCalendar = "daily";
        paths = map (x: "${config.users.users.sk.home}/${x}") [
          ".config/BraveSoftware"
          ".config/MusicBrainz"
          ".config/dconf/user"
          ".config/gconf/user"
          ".config/obsidian"
          ".config/remmina"
          ".lima"
          ".local/share/Anki"
          ".local/share/Anki2"
          ".local/share/anytype"
          ".local/share/bottles"
          ".local/share/remmina"
          ".mozilla"
          ".thunderbird"
          ".zotero"
        ];
      };
    system-data-maintenance = commonMaintenanceOpts // systemDataJobCommon;
  };

  sops.secrets = {
    restic-domashka-env = commonResticSopsSecretAttrs // {
      group = config.users.groups.restic-remote-domashka.name;
    };
    restic-content-repo = commonResticSopsSecretAttrs;
    restic-content-repo-password = commonResticSopsSecretAttrs;
    restic-sensitive-repo = commonResticSopsSecretAttrs;
    restic-sensitive-repo-password = commonResticSopsSecretAttrs;
    restic-system-data-repo = commonResticSopsSecretAttrs;
    restic-system-data-repo-password = commonResticSopsSecretAttrs;
    restic-user-data-repo = commonResticSopsSecretAttrs;
    restic-user-data-repo-password = commonResticSopsSecretAttrs;
    restic-user-media-repo = commonResticSopsSecretAttrs;
    restic-user-media-repo-password = commonResticSopsSecretAttrs;
  };

  # shared cache
  systemd.services = {
    restic-backups-content-maintenance = {
      environment.RESTIC_CACHE_DIR = mkForce config.systemd.services.restic-backups-content.environment.RESTIC_CACHE_DIR;
      serviceConfig.CacheDirectory = mkForce config.systemd.services.restic-backups-content.serviceConfig.CacheDirectory;
    };
    restic-backups-sensitive-maintenance = {
      environment.RESTIC_CACHE_DIR = mkForce config.systemd.services.restic-backups-sensitive.environment.RESTIC_CACHE_DIR;
      serviceConfig.CacheDirectory = mkForce config.systemd.services.restic-backups-sensitive.serviceConfig.CacheDirectory;
    };
    restic-backups-user-data-maintenance = {
      environment.RESTIC_CACHE_DIR = mkForce config.systemd.services.restic-backups-user-data.environment.RESTIC_CACHE_DIR;
      serviceConfig.CacheDirectory = mkForce config.systemd.services.restic-backups-user-data.serviceConfig.CacheDirectory;
    };
    restic-backups-user-media-maintenance = {
      environment.RESTIC_CACHE_DIR = mkForce config.systemd.services.restic-backups-user-media.environment.RESTIC_CACHE_DIR;
      serviceConfig.CacheDirectory = mkForce config.systemd.services.restic-backups-user-media.serviceConfig.CacheDirectory;
    };
    restic-backups-system-data-maintenance = {
      environment.RESTIC_CACHE_DIR = mkForce config.systemd.services.restic-backups-system-data.environment.RESTIC_CACHE_DIR;
      serviceConfig.CacheDirectory = mkForce config.systemd.services.restic-backups-system-data.serviceConfig.CacheDirectory;
    };
  };
}
