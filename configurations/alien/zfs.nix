{ ... }:
let
  commonRecvOptions = "ux recordsize o canmount=off";
in
{
  boot = {
    zfs = {
      forceImportRoot = false;
      extraPools = [ "evo970" ];
      requestEncryptionCredentials = true;
    };
  };

  services = {
    sanoid = {
      enable = true;
      interval = "*:0/10:0";
      templates = rec {
        default = {
          autoprune = true;
          autosnap = true;
          frequent_period = 10;
          frequently = 10;
          hourly = 24;
          daily = 32;
          weekly = 5;
          monthly = 0;
          yearly = 0;
        };
        minimal = default // {
          daily = 0;
          weekly = 0;
        };
        long_term = default // {
          monthly = 13;
          yearly = 100;
        };
        only_prune = {
          autoprune = true;
          autosnap = false;
        };
      };
      datasets = {
        "evo970/home".use_template = [ "long_term" ];
        "evo970/home/containers-storage".use_template = [ "default" ];
        "evo970/local/home-cache".use_template = [ "minimal" ];
        "evo970/system" = {
          use_template = [ "default" ];
          recursive = "zfs";
        };
        "wdc3/backups/alien/home" = {
          use_template = [
            "long_term"
            "only_prune"
          ];
        };
        "wdc3/backups/alien/home/containers-storage" = {
          use_template = [
            "minimal"
            "only_prune"
          ];
        };
        "wdc3/backups/alien/system" = {
          use_template = [
            "default"
            "only_prune"
          ];
          recursive = "zfs";
        };
      };
    };

    syncoid = {
      enable = true;
      interval = "yearly";
      localTargetAllow = [
        "canmount"
        "change-key"
        "compression"
        "create"
        "destroy"
        "mount"
        "mountpoint"
        "receive"
        "recordsize"
        "rollback"
      ];
      commands = {
        home = {
          source = "evo970/home";
          target = "wdc3/backups/alien/home";
          recursive = true;
          sendOptions = "w";
          recvOptions = commonRecvOptions;
        };
        system = {
          source = "evo970/system";
          target = "wdc3/backups/alien/system";
          recursive = true;
          sendOptions = "w";
          recvOptions = commonRecvOptions;
        };
      };
    };

    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };
}
