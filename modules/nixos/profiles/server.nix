#
# Some server host
#
{
  config,
  lib,
  self,
  ...
}:
{
  imports = with self.modules.nixos; [
    profile-common
    mixin-essential-server-packages
    mixin-no-docs
  ];

  # Given that our systems are headless, emergency mode is useless.
  # We prefer the system to attempt to continue booting so
  # that we can hopefully still access it remotely.
  boot.initrd.systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
    "emergency.service"
    "emergency.target"
  ];

  environment = {
    # Print the URL instead on servers
    variables.BROWSER = "echo";

    # Don't install the /lib/ld-linux.so.2 and /lib64/ld-linux-x86-64.so.2
    # stubs. Server users should know what they are doing.
    stub-ld.enable = lib.mkDefault false;
  };

  # No need for fonts on a server
  fonts.fontconfig.enable = lib.mkDefault false;

  # Make sure firewall is enabled
  networking.firewall.enable = true;

  programs = {
    command-not-found.enable = lib.mkDefault false;
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    # Enable SSH everywhere
    openssh.enable = true;
  };

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 7.5s.
      # If the hardware watchdog does not get a signal for 15s,
      # it will forcefully reboot the system.
      runtimeTime = lib.mkDefault "15s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = lib.mkDefault "30s";
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      kexecTime = lib.mkDefault "1m";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  # No mutable users by default
  users.mutableUsers = false;

  # Make sure the serial console is visible in qemu when testing the server configuration
  # with nixos-rebuild build-vm
  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;

  # freedesktop xdg files
  xdg = {
    autostart.enable = lib.mkDefault false;
    icons.enable = lib.mkDefault false;
    menus.enable = lib.mkDefault false;
    mime.enable = lib.mkDefault false;
    sounds.enable = lib.mkDefault false;
  };
}
