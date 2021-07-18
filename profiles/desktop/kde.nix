{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf getBin;
  libsForQt5 = pkgs.plasma5Packages;
  inherit (libsForQt5) kdeApplications kdeFrameworks plasma5;
  cfg = config.services.xserver.desktopManager.plasma5;
  sed = "${getBin pkgs.gnused}/bin/sed";
  activationScript = ''
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    rm -fv $HOME/.cache/icon-cache.kcache
    rm -fv ''${XDG_CONFIG_HOME}/menus/applications-merged/xdg-desktop-menu-dummy.menu
    trolltech_conf="''${XDG_CONFIG_HOME}/Trolltech.conf"
    if [ -e "$trolltech_conf" ]; then
        ${sed} -i "$trolltech_conf" -e '/nix\\store\|nix\/store/ d'
    fi
    rm -fv $HOME/.cache/ksycoca*
    ${libsForQt5.kservice}/bin/kbuildsycoca5
  '';
in
{
  environment.systemPackages =
    with pkgs;
    with libsForQt5;
    with plasma5;
    with kdeApplications;
    with kdeFrameworks;
    [
      ark
      krename
      plasma-applet-caffeine-plus
      plasma-systemmonitor # will replace ksysguard

      # overriden
      pkgs.krohnkite
    ];

  programs = {
    chromium.extensions = [
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # plasma integration
    ];
    partition-manager.enable = true;
  };

  security.pam.services.sddm.gnupg = {
    enable = true;
    noAutostart = true;
    storeOnly = true;
  };

  services.xserver = {
    displayManager = {
      lightdm.enable = false;
      sddm.enable = true;
      sessionPackages = [
        (pkgs.plasma-workspace.overrideAttrs
          (old: { passthru.providedSessions = [ "plasmawayland" ]; }))
      ];
    };
    desktopManager.plasma5.enable = true;
  };

  systemd.user.services = {
    plasma-early-setup = mkIf cfg.enable {
      description = "Early Plasma setup";
      wantedBy = [ "graphical-session-pre.target" ];
      serviceConfig.Type = "oneshot";
      stopIfChanged = false;
      script = activationScript;
    };

    plasma-run-with-systemd = {
      description = "Run KDE Plasma via systemd";
      wantedBy = [ "basic.target" ];
      serviceConfig.Type = "oneshot";
      stopIfChanged = false;
      script = ''
        XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
        ${kdeFrameworks.kconfig}/bin/kwriteconfig5 \
          --file startkderc --group General --key systemdBoot true
      '';
    };
  };
}
