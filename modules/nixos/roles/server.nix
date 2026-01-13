#
# Base server role
#
{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.roles.server;
in
{
  imports = with self.modules.nixos; [
    program-helix
    misc-common-mixin
    misc-no-docs
  ];

  options.roles.server.enable = mkEnableOption "Base server role";

  config = mkIf cfg.enable {
    custom.applists = {
      admin = mkDefault true;
      cliTools = mkDefault true;
      hardware = mkDefault true;
      networking = mkDefault true;
    };
    custom.locale.flavor = mkDefault "en_RU";
    custom.no-docs.enable = mkDefault true;

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
      stub-ld.enable = mkDefault false;
    };

    # Restrict the number of boot entries to prevent full /boot partition.
    #
    # Servers don't need too many generations.
    boot.loader.grub.configurationLimit = lib.mkDefault 5;
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 5;

    documentation.nixos.enable = mkDefault false;

    # No need for fonts on a server
    fonts.fontconfig.enable = mkDefault false;

    # Make sure firewall is enabled
    networking.firewall.enable = true;

    programs.git.package = mkDefault pkgs.gitMinimal;

    custom.helix = {
      enable = lib.mkDefault true;
      defaultEditor = mkDefault true;
      viAlias = true;
      vimAlias = true;
    };

    custom.htop.enable = mkDefault true;

    security.sudo.wheelNeedsPassword = false;

    # Enable SSH everywhere
    service.openssh.enable = true;

    systemd = {
      # Given that our systems are headless, emergency mode is useless.
      # We prefer the system to attempt to continue booting so
      # that we can hopefully still access it remotely.
      enableEmergencyMode = false;

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      settings.Manager = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 7.5s.
        # If the hardware watchdog does not get a signal for 15s,
        # it will forcefully reboot the system.
        RuntimeWatchdogSec = mkDefault "15s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        RebootWatchdogSec = mkDefault "30s";
        # Forcefully reboot when a host hangs after kexec.
        # This may be the case when the firmware does not support kexec.
        KExecWatchdogSec = mkDefault "1m";
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };

    # UTC everywhere!
    time.timeZone = mkDefault "UTC";

    # No mutable users by default
    users.mutableUsers = false;

    # Make sure the serial console is visible in qemu when testing the server configuration
    # with nixos-rebuild build-vm
    virtualisation.vmVariant.virtualisation.graphics = mkDefault false;

    # freedesktop xdg files
    xdg = {
      autostart.enable = mkDefault false;
      icons.enable = mkDefault false;
      menus.enable = mkDefault false;
      mime.enable = mkDefault false;
      sounds.enable = mkDefault false;
    };
  };
}
