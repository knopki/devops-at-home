{
  config,
  lib,
  inputs,
  pkgs,
  self,
  ...
}:
let
  inherit (builtins) mapAttrs;
  inherit (lib.modules) mkIf mkAliasOptionModule;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.lists) flatten optional optionals;
  inherit (lib.attrsets) mapAttrsToList mergeAttrsList;
  inherit (self.lib.systemd) pathToSystemdDeviceName;
  cfg = config.custom.preservation;

  hasPackage = p: builtins.elem p config.environment.systemPackages;
  hasPackageName = name: lib.any (p: (lib.getName p) == name) config.environment.systemPackages;

  preserveAtUserTemplatesSubmodule = _: {
    options = {
      auto.enable = mkEnableOption "Essential + autodetected paths";
      chezmoi.enable = mkEnableOption "Chezmoi";
      secrets.enable = mkEnableOption "Secrets and keyrings";
      xdgTmpfiles.enable = mkEnableOption "Create tmpfiles.d for XDG dirs";
    };
  };

  preserveAtTemplatesSubmodule = _: {
    options = {
      auto.enable = mkEnableOption "Essential + autodetected paths";
      vm.enable = mkEnableOption "VMs and containers";

      users = mkOption {
        type = with lib.types; attrsOf (submodule preserveAtUserTemplatesSubmodule);
        description = ''
          Per-user templates.
        '';
        default = { };
      };
    };
  };

  mkInitrdTmpfilesRules =
    preserveName: stateCfg:
    let
      preservePath = config.preservation.preserveAt.${preserveName}.persistentStoragePath;
      filename = "/sysroot${preservePath}/etc/machine-id";
    in
    optional stateCfg.auto.enable {
      "${filename}".f.argument = "uninitialized";
    };

  mkUserTmpfilesRules =
    preserveAtTemplates:
    let
      rules = [
        "d %C              0700 - - -" # create XDG_CACHE_HOME
        "f %C/CACHEDIR.TAG 0644 - - - \"Signature: 8a477f597d28d172789f06886806bc55\""
        "d %h/.local/share 0700 - - -" # create XDG_DATA_HOME
        "d %S              0700 - - -" # create XDG_STATE_DIR
      ];
      usernames = flatten (
        mapAttrsToList (
          _: preserveAtTemplate:
          mapAttrsToList (username: user: optional user.xdgTmpfiles.enable username) preserveAtTemplate.users
        ) preserveAtTemplates
      );
    in
    mergeAttrsList (map (name: { ${name}.rules = rules; }) usernames);

  mkMachineIdCommitSvc =
    preserveName: stateCfg:
    let
      preservePath = config.preservation.preserveAt.${preserveName}.persistentStoragePath;
      svcOverrides = {
        unitConfig.ConditionPathIsMountPoint = [
          ""
          "${preservePath}/etc/machine-id"
        ];
        serviceConfig.ExecStart = [
          ""
          "systemd-machine-id-setup --commit --root ${preservePath}"
        ];
      };
    in
    if stateCfg.auto.enable then svcOverrides else { };

  mkPreserveAtUser =
    _username: stateCfg:
    let
      essentialDirs = [
        {
          directory = ".config/systemd";
          parent.mode = "0700";
        }
        ".config/environment.d"
        ".config/git"
        ".config/nix"
        ".config/user-tmpfiles.d"
        {
          directory = ".local/state";
          parent.mode = "0700";
        }
        ".local/bin"
        ".local/share/systemd"
        ".local/share/Trash"
      ];
      autodetectedDirs =
        optionals config.services.graphical-desktop.enable [
          ".config/autostart"
          ".config/menus"
          ".local/share/application"
          ".local/share/gvfs-metadata"
          ".local/share/icons"
          ".local/share/mime"
          ".local/share/themes"
        ]
        ++ optional config.services.gvfs.enable ".local/share/gvfs-metadata"
        ++ optionals config.services.desktopManager.cosmic.enable [
          ".cache/cosmic-settings/wallpapers"
          ".config/cosmic"
        ]
        ++ optionals (hasPackage pkgs.chezmoi) [
          ".config/chezmoi"
          ".local/share/chezmoi"
        ]
        ++ optional (hasPackage pkgs.anydesk) ".anydesk"
        ++ optionals (hasPackage pkgs.czkawka) [
          ".cache/czkawka"
          ".config/czkawka"
        ]
        ++ optional (hasPackage pkgs.deja-dup) ".cache/deja-dup"
        ++ optional (hasPackage pkgs.fclones) ".cache/fclones"
        ++ optional (hasPackage pkgs.restic || config.services.restic.backups != { }) ".cache/restic"
        ++ optional (hasPackage pkgs.aliza) ".config/Aliza"
        ++
          optionals
            (lib.any hasPackage [
              pkgs.anki
              pkgs.anki-bin
            ])
            [
              ".local/share/Anki"
              ".local/share/Anki2"
            ]
        ++ optionals (hasPackage pkgs.anytype) [
          ".config/anytype"
          ".local/share/anytype"
        ]
        ++ optionals (hasPackage pkgs.atuin) [
          ".config/atuin"
          ".local/share/atuin"
        ]
        ++ optional (hasPackage pkgs.brave) ".config/BraveSoftware"
        ++ optional (lib.any hasPackage [
          pkgs.bottles
          pkgs.bottles-unwrapped
        ]) ".local/share/bottles"
        ++ optional (hasPackage pkgs.btop) ".config/btop"
        ++ optional (hasPackage pkgs.cachix) ".config/cachix"
        ++ optional (hasPackage pkgs.cherry-studio) ".config/CherryStudio"
        ++ optional (hasPackage config.programs.dconf.enable) ".config/dconf"
        ++ optional (hasPackage pkgs.devenv) ".local/share/devenv"
        ++ optional (hasPackage pkgs.direnv) ".local/share/direnv"
        ++ optionals (hasPackage pkgs.docker) [
          ".config/docker"
          ".docker"
        ]
        ++ optionals (hasPackage pkgs.fish || config.programs.fish.enable) [
          ".cache/fish"
          ".config/fish"
          ".local/share/fish"
        ]
        ++ optional (hasPackage pkgs.framesh) ".config/frame"
        ++ optional (hasPackage pkgs.freerdp) ".config/freerdp"
        ++ optional (lib.any hasPackage (
          with pkgs;
          [
            google-cloud-sdk
            google-cloud-sdk-gce
          ]
        )) ".config/gcloud"
        ++ optional (hasPackage pkgs.handbrake) ".config/ghb"
        ++ optionals (hasPackage pkgs.accountsservice || config.services.accounts-daemon.enable) [
          ".config/goa-1.0"
          ".config/libaccounts-glib"
        ]
        ++ optional (hasPackage pkgs.hardinfo2) ".config/hardinfo2"
        ++ optional (hasPackage pkgs.helix) ".config/helix"
        ++ optional (hasPackage pkgs.htop || config.programs.htop.enable) ".config/htop"
        ++ optional (hasPackage pkgs.keepassxc) ".config/keepassxc"
        ++ optionals (hasPackage pkgs.khal) [
          ".config/khal"
          ".local/share/khal"
        ]
        ++ optional (hasPackage pkgs.khard) ".config/khard"
        ++ optional (hasPackage pkgs.lazydocker) ".config/lazydocker"
        ++ optional (hasPackage pkgs.lazygit) ".config/lazygit"
        ++ optional (hasPackage pkgs.ledger-live-desktop) ".config/Ledger Live"
        ++ optional (hasPackage pkgs.lima) {
          directory = ".lima";
          mode = "0700";
        }
        ++ optional (hasPackage pkgs.mpv || hasPackageName "mpv") ".config/mpv"
        ++ optional (hasPackage pkgs.picard) ".config/MusicBrainz"
        ++ optionals (hasPackage pkgs.podman || config.virtualisation.podman.enable) [
          ".config/containers"
          ".local/share/containers"
        ]
        ++ optional (hasPackage pkgs.naps2) ".config/naps2"
        ++ optional (hasPackage pkgs.nextcloud-client) ".config/NextCloud"
        ++ optional (hasPackage pkgs.nix-inspect) ".config/nix-inspect"
        ++ optional (hasPackage pkgs.nushell) ".config/nushell"
        ++ optional (hasPackage pkgs.obsidian) ".config/obsidian"
        ++ optionals (hasPackage pkgs.onlyoffice-desktopeditors) [
          ".config/onlyoffice"
          ".local/share/onlyoffice"
        ]
        ++ optionals (hasPackage pkgs.opencode) [
          ".config/opencode"
          ".local/share/opencode"
        ]
        ++ optional (hasPackage pkgs.pdfarranger) ".config/pdfarranger"
        ++ optional (hasPackage pkgs.pinta) ".config/Pinta"
        ++
          optionals
            (lib.any hasPackage [
              pkgs.qalculate-gtk
              pkgs.qalculate-qt
            ])
            [
              ".config/qalculate"
              ".local/share/qalculate"
            ]
        ++
          optionals
            (lib.any hasPackage [
              pkgs.qbittorrent
              pkgs.qbittorrent-enchanced
            ])
            [
              ".config/qBittorrent"
              ".local/share/qBittorrent"
            ]
        ++ optionals (hasPackage pkgs.ranger) [
          ".config/ranger"
          ".local/share/ranger"
        ]
        ++ optionals (hasPackage pkgs.rclone) [
          ".cache/rclone"
          ".config/rclone"
        ]
        ++ optionals (hasPackage pkgs.remmina) [
          ".config/remmina"
          ".local/share/remmina"
        ]
        ++ optional (hasPackage pkgs.rustic) ".config/rustic"
        ++ optional config.hardware.sane.enable ".sane"
        ++ optional (hasPackage pkgs.szyszka) ".config/szyszka"
        ++ optional (hasPackage pkgs.telegram-desktop) ".local/share/TelegramDesktop"
        ++ optional (hasPackage pkgs.throne) ".config/Throne"
        ++ optional (config.programs.thunderbird.enable || hasPackageName "thunderbird") ".thunderbird"
        ++ optional (hasPackage pkgs.tor-browser) ".tor project"
        ++ optional (hasPackage pkgs.vdirsyncer) ".config/vdirsyncer"
        ++ optional (hasPackage pkgs.uv) ".local/share/uv"
        ++ optional (hasPackage pkgs.yandex-cloud) ".config/yandex-cloud"
        ++
          optionals (hasPackage pkgs.zed-editor || hasPackage pkgs.zed-editor-fhs || hasPackageName "zed")
            [
              ".config/zed"
              ".local/share/zed"
            ]
        ++
          optionals
            (lib.any hasPackage [
              pkgs.zotero
              pkgs.zotero-beta
            ])
            [
              ".local/share/Zotero"
              ".zotero"
            ];
      autoDirs = optionals stateCfg.auto.enable (essentialDirs ++ autodetectedDirs);
      secretDirs =
        optionals stateCfg.secrets.enable [
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
          ".config/sops"
        ]
        ++ optional (hasPackage pkgs.electrum) ".electrum";
      essentialFiles = [
        ".bash_history"
        ".bash_profile"
        ".bashrc"
        ".python_history"
      ];
      autodetectFiles =
        optionals config.services.graphical-desktop.enable [
          ".config/mimeapps.list"
          ".config/user-dirs.conf"
          ".config/user-dirs.dirs"
          ".config/user-dirs.locale"
          ".face"
          ".face.icon"
          ".local/share/mimeapps.list"
          ".local/share/recently-used.xbel"
          ".local/share/user-places.xbel"
        ]
        ++ optional config.services.desktopManager.cosmic.enable ".config/cosmic-initial-setup-done"
        ++ optional (hasPackage pkgs.curl) ".curlrc"
        ++ optional (hasPackage pkgs.gnupg) ".pam-gnupg"
        ++ optional (hasPackage pkgs.electrum) ".config/electrumrc"
        ++ optional (hasPackage pkgs.keepassxc) ".config/KeePassXCrc"
        ++ optional (config.programs.starship.enable || hasPackage pkgs.starship) ".config/starship.toml"
        ++ optional (hasPackage pkgs.telegram-desktop) ".config/TelegramDesktoprc"
        ++ optional (hasPackage pkgs.terraform) ".terraformrc"
        ++ optional (hasPackage pkgs.trashy) ".config/trashrc"
        ++ optional (hasPackage pkgs.wget) ".wgetrc";
      autoFiles = optionals stateCfg.auto.enable (essentialFiles ++ autodetectFiles);
    in
    {
      directories = autoDirs ++ secretDirs;
      files = autoFiles;
    };

  mkPreserveAt =
    _: stateCfg:
    let
      autodetectedDirs =
        optional config.networking.networkmanager.enable "/etc/NetworkManager/system-connections"
        ++ optional config.hardware.bluetooth.enable "/var/lib/bluetooth"
        ++ optional config.services.fwupd.enable "/var/lib/fwupd"
        ++ optional config.services.fprintd.enable "/var/lib/fprint"
        ++ optional config.services.printing.enable "/var/lib/cups"
        ++ optional config.services.accounts-daemon.enable "/var/lib/AccountsService"
        ++ optional config.services.power-profiles-daemon.enable "/var/lib/power-profiles-daemon"
        ++ optional config.services.upower.enable "/var/lib/upower"
        ++ optional (hasPackage pkgs.sbctl) "/var/lib/sbctl";
      essentialDirs = [
        "/var/lib/systemd/backlight"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/rfkill"
        "/var/lib/systemd/timers"
        "/var/log"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];
      autoDirs = optionals stateCfg.auto.enable (essentialDirs ++ autodetectedDirs);

      autodetectedFiles =
        optionals config.networking.networkmanager.enable [
          "/var/lib/NetworkManager/secret_key"
          "/var/lib/NetworkManager/seen-bssids"
          "/var/lib/NetworkManager/timestamps"
        ]
        ++ optional config.services.logrotate.enable {
          file = "/var/lib/logrotate.status";
          how = "symlink";
        }
        ++ optional config.services.usbguard.enable "/var/lib/usbguard/rules.conf";
      essentialFiles = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
          createLinkTarget = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        "/etc/ssh/ssh_host_rsa_key.pub"
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
          inInitrd = true;
        }
        "/etc/ssh/ssh_host_ed25519_key.pub"
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];
      autoFiles = optionals stateCfg.auto.enable (essentialFiles ++ autodetectedFiles);
      vmDirs = optionals stateCfg.vm.enable (
        [
          "/var/lib/machines"
        ]
        ++ optional config.virtualisation.libvirtd.enable "/var/lib/libvirt"
        ++ optional config.virtualisation.podman.enable "/var/lib/containers"
        ++ optionals config.virtualisation.docker.enable [
          "/var/lib/docker"
          "/var/lib/dockershim"
        ]
      );
    in
    {
      commonMountOptions = [
        "x-gvfs-hide"
        "x-gdu.hide"
      ];
      directories = autoDirs ++ vmDirs;
      files = autoFiles;

      users = mapAttrs mkPreserveAtUser stateCfg.users;
    };
in
{
  imports = [
    inputs.preservation.nixosModules.preservation
    (mkAliasOptionModule [ "custom" "preservation" "preserveAt" ] [ "preservation" "preserveAt" ])
  ];

  options.custom.preservation = {
    enable = mkEnableOption "custom additions to preservation module";

    preserveAtTemplates = mkOption {
      type = with lib.types; attrsOf (submodule preserveAtTemplatesSubmodule);
      description = ''
        Specify a set of templates for the corresponding state.
      '';
      default = { };
    };

    resetBtrfsRoot = {
      enable = mkEnableOption "Reset root partition on reboot";
      device = mkOption {
        type = lib.types.str;
        description = "Parent device of the root FS (absolute path)";
        default = config.fileSystems."/".device;
      };
      subvol = mkOption {
        type = lib.types.str;
        description = "Subvolume name of the root FS.";
        default = "@";
      };
    };
  };

  config = mkIf cfg.enable {
    preservation.enable = true;

    preservation.preserveAt = mapAttrs mkPreserveAt cfg.preserveAtTemplates;

    boot.initrd.systemd.tmpfiles.settings.preservation = mergeAttrsList (
      flatten (mapAttrsToList mkInitrdTmpfilesRules cfg.preserveAtTemplates)
    );

    systemd.services.systemd-machine-id-commit = mergeAttrsList (
      mapAttrsToList mkMachineIdCommitSvc cfg.preserveAtTemplates
    );

    systemd.user.tmpfiles.users = mkUserTmpfilesRules cfg.preserveAtTemplates;

    boot.initrd.systemd.services.rollback =
      let
        rootSystemdDevName = pathToSystemdDeviceName cfg.resetBtrfsRoot.device;
      in
      mkIf cfg.resetBtrfsRoot.enable {
        description = "Rollback BTRFS @root subvolume to a pristine state";
        wantedBy = [ "initrd.target" ];
        requires = [ rootSystemdDevName ];
        after = [ rootSystemdDevName ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          set -euo pipefail
          mkdir -p /mnt
          mount -t btrfs -o subvol=/ ${cfg.resetBtrfsRoot.device} /mnt

          # create initial snapshot if not exists
          if [ ! -e /mnt/@root-blank ]; then
            echo "Creating initial blank snapshot..."
            btrfs subvolume snapshot -r /mnt/${cfg.resetBtrfsRoot.subvol} /mnt/@root-blank
          fi

          # archive old root
          mkdir -p /mnt/.snapshots
          timestamp=$(date +%Y%m%dT%H%M)
          mv /mnt/${cfg.resetBtrfsRoot.subvol} "/mnt/.snapshots/root.$timestamp" || true

          # create root device from snapshot
          btrfs subvolume snapshot /mnt/@root-blank /mnt/${cfg.resetBtrfsRoot.subvol}

          # workaround of https://github.com/nixos/nixpkgs/issues/462556
          mkdir -p /mnt/${cfg.resetBtrfsRoot.subvol}/usr/bin

          umount /mnt
        '';
      };
  };
}
