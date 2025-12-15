{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) toFile;
  inherit (lib.lists) foldl;

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
  # File extensions exclude patterns
  genericExcludedExtensions = [
    "*.back"
    "*.bak"
    "*.bkp"
    "*.cache"
    "*.chk"
    "*.dmp"
    "*.dump"
    "*.err"
    "*.lock"
    "*.lockfile"
    "*.log"
    "*.log[0-9]"
    "*.log.[0-9]"
    "*.log.[0-9][0-9]"
    "*.old"
    "*.tmp"
    "*.temp"
    "*.pid"

    # Browser not finished downloads
    "*.download"
    "*.crdownload"
    "*.part"

    # Python compiled files
    "*.py[cod]"
  ];
  genericExcludes = [
    # System trash directory
    "**/.Trash"

    # MacOS files
    "**/.DS_Store"

    # Generic directories / files
    "**/cache*.db"

    # Generic Thumbs files
    "**/thumb*.db"
    "**/icon*.db"
    "**/icons*.db"
    "**/*cache.db"
    "**/iconcache*.db"

    # Generic Thumbs directories
    "**/.thumbnails"
    "**/thumbnails"
    "**/thumbcache*.db"

    # Generic tmp dir
    "**/Temp"
    "**/tmp"

    # Generic caches dir for most navigators
    "**/.cache"
    "**/Font*Cache"
    "**/File*Cache"
    "**/Dist*Cache"
    "**/Native*Cache"
    "**/Play*Cache"
    "**/Asset*Cache"
    "**/Activities*Cache"
    "**/Script*Cache"
    "**/Gpu*Cache"
    "**/Code*Cache"
    "**/Local*Cache"
    "**/Session*Cache"
    "**/Web*Cache"
    "**/JS*Cache"
    "**/CRL*Cache"
    "**/GrShader*Cache"
    "**/Shader*Cache"
    "**/Cache_data"
    "**/Cache"
    "**/Caches"
    "**/CacheStorage"
    "**/Cachedata"
    "**/CachedFiles"
    "**/Cache*Storage"
    "**/Cache*data"
    "**/Cached*Files"
    # firefox specific
    "**/cache2"

    # npm
    "**/node_modules"
    "**/npm-cache"

    # Thumbnails folder
    "**/Thumbnails"

    # Lock files
    "**/lock"
    "**/lockfile"

    # Generic cookie files and folders
    "**/Cookie"

    # Python cache files
    "**/__pycache__"

    # Speific coverage files
    "**/.tox"
    "**/.nox"
    "**/.coverage"
    "**/.pytest_cache"

    # Python VENV files
    "**/.venv"
    "**/env.bak"
    "**/venv.bak"

    # PyCharm
    "**/.idea"

    # VSCore
    "**/.vscode"
  ];
  nixLikeExcludes = [
    # Generic unix sys path excludes
    "/dev"
    "lost+found"
    "/media"
    "/proc"
    "/sys"
    "/run"
    "/selinux"
    "/var/cache"
    "/var/log"
    "/var/run"
    "/var/tmp"
    "/tmp"

    # More MacOS specific sys path excludes
    "/afs"
    "/Network"
    "/automount"
    "/private/Network"
    "/private/tmp"
    "/private/var/tmp"
    "/private/var/folders"
    "/private/var/run"
    "/private/var/spool/postfix"
    "/private/var/automount"
    "/private/var/db/fseventsd"
    "/Previous Systems"

    # Home directory excludes mostly found on unixes
    "/home/*/Downloads"
    "/home/*/Library"
    "/home/*/snap"
    "/home/*/.Trash"
    "/home/*/.bundle"
    "/home/*/.cache"
    "/home/*/.dbus"
    "/home/*/.debug"
    "/home/*/.gvfs"
    "/home/*/.local/share/gvfs-metadata"
    "/home/*/.local/share/Trash"
    "/home/*/.dropbox"
    "/home/*/.dropbox-dist"
    "/home/*/.local/pipx"
    "/home/*/.local/share/Trash"
    "/home/*/.npm"
    "/home/*/.pyenv"
    "/home/*/.thumbnails"
    "/home/*/.virtualenvs"
    "/home/*/.recently-used"
    "/home/*/.xession-errors"
    "/home/*/OneDrive"
    "/home/*/Dropbox"
    "/home/*/SkyDrive*"
    "$HOME/Downloads"
    "$HOME/Library"
    "$HOME/snap"
    "$HOME/.Trash"
    "$HOME/.bundle"
    "$HOME/.cache"
    "$HOME/.dbus"
    "$HOME/.debug"
    "$HOME/.gvfs"
    "$HOME/.local/share/gvfs-metadata"
    "$HOME/.local/share/Trash"
    "$HOME/.dropbox"
    "$HOME/.dropbox-dist"
    "$HOME/.local/pipx"
    "$HOME/.local/share/Trash"
    "$HOME/.npm"
    "$HOME/.pyenv"
    "$HOME/.thumbnails"
    "$HOME/.virtualenvs"
    "$HOME/.recently-used"
    "$HOME/.xession-errors"
    "$HOME/OneDrive"
    "$HOME/Dropbox"
    "$HOME/SkyDrive*"

    # Electron Apps
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
    "$HOME/.config/**/blob_storage"
    "$HOME/.config/**/Application Cache"
    "$HOME/.config/**/Cache"
    "$HOME/.config/**/CachedData"
    "$HOME/.config/**/Code Cache"
    "$HOME/.config/**/GPUCache"
    "$HOME/.var/app/**/blob_storage"
    "$HOME/.var/app/**/Application Cache"
    "$HOME/.var/app/**/Cache"
    "$HOME/.var/app/**/CachedData"
    "$HOME/.var/app/**/Code Cache"
    "$HOME/.var/app/**/GPUCache"
    "$HOME/.var/app/**/GPUCache"

    # Some morre generic MacOS exclusions
    "**/Network Trash Folder"
    "**/.fseventsd*"
    "**/.Spotlight-*"
    "**/*Mobile*Backups"
  ];
  commonExcludes = genericExcludedExtensions ++ genericExcludes ++ nixLikeExcludes;
  commonExcludesFile = mkIgnoresFile commonExcludes;

  commonBackupsOpts = {
    user = resticUser.name;
    createWrapper = true;
    package = superRestic;
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "3h";
      Persistent = true;
    };
    extraBackupArgs = [
      "--cleanup-cache"
      "--exclude-caches"
      "--pack-size=128"
      "--ignore-ctime"
      "--ignore-inode"
      "--retry-lock 24h"
      "--no-scan"
      "--exclude-file=${commonExcludesFile}"
      "--exclude-file=${config.users.users.sk.home}/.resticignore"
    ];
    backupPrepareCommand = "${superRestic}/bin/restic unlock";
  };
  commonMaintenanceOpts = {
    user = resticUser.name;
    createWrapper = true;
    timerConfig = {
      OnCalendar = "weekly";
      RandomizedDelaySec = "3h";
      Persistent = true;
    };
    checkOpts = [
      "--retry-lock 24h"
      "--read-data-subset=128M"
    ];
    pruneOpts = [
      "--retry-lock 24h"
      "--pack-size=128"
      "--keep-within-yearly 10y"
      "--keep-within-monthly 1y"
      "--keep-within-weekly 1m"
      "--keep-within-daily 7d"
      "--keep-within-hourly 1d"
    ];
  };

  contentJobRepoConfig = {
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-content-repo.path;
    passwordFile = config.sops.secrets.restic-content-repo-password.path;
  };

  sensitiveJobRepoConfig = {
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-sensitive-repo.path;
    passwordFile = config.sops.secrets.restic-sensitive-repo-password.path;
  };

  userDataJobRepoConfig = {
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-user-data-repo.path;
    passwordFile = config.sops.secrets.restic-user-data-repo-password.path;
  };

  userMediaJobRepoConfig = {
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-user-media-repo.path;
    passwordFile = config.sops.secrets.restic-user-media-repo-password.path;
  };

  systemDataJobRepoConfig = {
    environmentFile = config.sops.secrets.restic-domashka-env.path;
    repositoryFile = config.sops.secrets.restic-system-data-repo.path;
    passwordFile = config.sops.secrets.restic-system-data-repo-password.path;
  };
in
{
  #
  # Users & Groups
  #
  # Restic system user with capability to read all files
  # via access to restic security wrapper
  users.users.restic = {
    isSystemUser = true;
    description = "Restic backup user";
    group = "restic";
  };
  users.groups.restic = { };
  # Group with access to remote repositories
  users.groups.restic-remote-domashka.members = [
    config.users.users.restic.name
    config.users.users.sk.name
  ];
  # Group with access to remote repository's password
  users.groups.restic-repos.members = [
    config.users.users.restic.name
    config.users.users.sk.name
  ];

  # Secrets
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

  # Security wrapper that allows restic binary to read
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
      // contentJobRepoConfig
      // {
        timerConfig.OnCalendar = "daily";
        paths = (
          map (x: "${config.users.users.sk.home}/${x}") [
            "music"
            "videos"
          ]
        );
      };
    content-maintenance = commonMaintenanceOpts // contentJobRepoConfig;

    sensitive =
      commonBackupsOpts
      // sensitiveJobRepoConfig
      // {
        paths = map (x: "${config.users.users.sk.home}/${x}") [
          ".config/cachix"
          ".config/gcloud"
          ".config/rclone"
          ".config/sops/age"
          ".electrum"
          ".gnupg"
          ".local/share/keyrings"
          "secrets"
        ];
      };
    sensitive-shell-history =
      commonBackupsOpts
      // sensitiveJobRepoConfig
      // {
        paths = map (x: "${config.users.users.sk.home}/${x}") [
          ".local/share/atuin"
          ".local/share/fish"
        ];
      };
    sensitive-maintenance = commonMaintenanceOpts // sensitiveJobRepoConfig;

    user-data =
      commonBackupsOpts
      // userDataJobRepoConfig
      // {
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
    user-data-maintenance = commonMaintenanceOpts // userDataJobRepoConfig;

    user-media =
      commonBackupsOpts
      // userMediaJobRepoConfig
      // {
        timerConfig.OnCalendar = "daily";
        paths = (
          map (x: "${config.users.users.sk.home}/${x}") [
            "pics"
          ]
        );
      };
    user-media-maintenance = commonMaintenanceOpts // userMediaJobRepoConfig;

    system-data =
      let
        excludes = [ "/var/lib/lampac/dlna/*" ];
        excludeFile = mkIgnoresFile excludes;
      in
      commonBackupsOpts
      // systemDataJobRepoConfig
      // {
        extraBackupArgs = commonBackupsOpts.extraBackupArgs ++ [
          "--exclude-file=${excludeFile}"
        ];
        paths = [
          "/var/lib/isponsorblocktv"
          "/var/lib/lampac"
        ]
        ++ (map (x: "${config.users.users.sk.home}/${x}") [
          ".config/BraveSoftware"
          ".config/MusicBrainz"
          ".config/dconf/user"
          ".config/gconf/user"
          ".config/obsidian"
          ".config/opencode"
          ".config/remmina"
          ".lima"
          ".local/share/Anki"
          ".local/share/Anki2"
          ".local/share/anytype"
          ".local/share/bottles"
          ".local/share/remmina"
          ".local/share/opencode"
          ".mozilla"
          ".thunderbird"
          ".zotero"
        ]);
      };
    system-data-maintenance = commonMaintenanceOpts // systemDataJobRepoConfig;
  };
}
