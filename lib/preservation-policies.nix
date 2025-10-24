{ ... }:
{
  commonSystemPresertveAt = {
    commonMountOptions = [
      "x-gvfs-hide"
      "x-gdu.hide"
    ];
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      "/var/lib/fwupd"
      "/var/lib/libvirt"
      "/var/lib/power-profiles-daemon"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/rfkill"
      "/var/lib/systemd/timers"
      "/var/log"
      {
        directory = "/var/lib/nixos";
        inInitrd = true;
      }
    ];
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "symlink";
        configureParent = true;
        inInitrd = true;
      }
      "/var/lib/usbguard/rules.conf"

      # creates a symlink on the volatile root
      # creates an empty directory on the persistent volume, i.e. /state/var/lib/systemd
      # does not create an empty file at the symlink's target (would require `createLinkTarget = true`)
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
        configureParent = true;
      }
    ];
  };

  commonUserTmpfilesRules = [
    "d %C              0700 - - -" # create XDG_CACHE_HOME
    "d %h/.config      0700 - - -" # create XDG_CONFIG_HOME
    "d %h/.local       0700 - - -"
    "d %h/.local/share 0700 - - -" # create XDG_DATA_HOME
    "d %S              0700 - - -" # create XDG_STATE_DIR
  ];
}
