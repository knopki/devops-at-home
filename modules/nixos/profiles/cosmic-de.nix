{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.profiles.cosmic-de;
in
{
  options.profiles.cosmic-de.enable = mkEnableOption "Enable Cosmis DE profile";
  # no SSH agent
  config = mkIf cfg.enable {

    environment.sessionVariables = {
      # to make Clipboard Manager work
      COSMIC_DATA_CONTROL_ENABLED = 1;
      # fix flickering on AMD GPUs
      # COSMIC_DISABLE_DIRECT_SCANOUT = "true";
      # enable Ozone Wayland support in Chromium and Electron
      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = with pkgs; [
      (lib.hiPrio cosmic-icons) # no need to install by this will fix collisions

      # Look & feel
      cosmic-ext-tweaks
      cosmic-ext-applet-caffeine
      gnome-themes-extra # is it really needed?
      ffmpegthumbnailer # cosmic files will use it to create video thumbs

      # get some DE parts from GNOME
      baobab
      resources
      gparted
      papers # alternative to cosmic reader
      cosmic-reader # not ready to be a default pdf viewer
      file-roller # archive management
      gnome-calendar
      gnome-characters
      gnome-contacts
      gnome-font-viewer
      kooha
      loupe

      hardinfo2 # TODO: create module

      wl-clipboard

      config.programs.gnupg.agent.pinentryPackage
    ];

    programs = {
      gnupg.agent.pinentryPackage = mkDefault pkgs.pinentry-gnome3;
      gnome-disks.enable = mkDefault true;
      firefox.preferences = {
        # disable libadwaita theming for Firefox
        "widget.gtk.libadwaita-colors.enabled" = mkDefault false;
      };
      seahorse.enable = mkDefault true;
    };

    qt = {
      enable = mkDefault true;
      platformTheme = mkDefault "gnome";
      style = mkDefault "adwaita-dark";
    };

    services = {
      udev.packages = [ pkgs.gnome-settings-daemon ];

      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.enable = true;
      desktopManager.cosmic.xwayland.enable = true;

      blueman.enable = mkDefault true;
      gnome = {
        evolution-data-server.enable = mkDefault true;
        gcr-ssh-agent.enable = mkDefault true;
        gnome-online-accounts.enable = mkDefault true;
        gnome-settings-daemon.enable = mkDefault true;
        localsearch.enable = mkDefault true;
      };
    };

    # Hack to fix SSH agent by @manuel-plavsic
    systemd.user.services.link-gcr-ssh = mkIf config.services.gnome.gcr-ssh-agent.enable {
      description = "Link GCR SSH agent socket into keyring path";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        # Wait for the GCR SSH socket at /run/user/$UID/gcr/ssh to appear,
        # checking every 0.25 seconds, up to a maximum of 5000 attempts
        # (~20 minutes), then create a hard link at /run/user/$UID/keyring/ssh.
        # If the socket never appears, the script exits gracefully.
        ExecStart = pkgs.writeShellScript "link-gcr-ssh" ''
          for i in $(seq 1 5000); do
            if [ -S /run/user/$UID/gcr/ssh ]; then
              break
            fi
            sleep 0.25
          done

          if [ ! -S /run/user/$UID/gcr/ssh ]; then
            echo "GCR socket not found after waiting, skipping link"
            exit 0
          fi

          mkdir -p /run/user/$UID/keyring
          ln -f /run/user/$UID/gcr/ssh /run/user/$UID/keyring/ssh
        '';
      };
    };

    # Patch cosmic-session to use correct gcr-ssh-agent socket path
    # Upstream issue: https://github.com/pop-os/cosmic-session/issues/148
    # Author: @MaxBullett
    # This is better than above but cosmic-session rebuild is required
    # nixpkgs.overlays = [
    #   (final: prev: {
    #     cosmic-session = prev.cosmic-session.overrideAttrs (oldAttrs: {
    #       postPatch = (oldAttrs.postPatch or "") + ''
    #         substituteInPlace data/start-cosmic \
    #           --replace-fail '/keyring/ssh' '/gcr/ssh'
    #       '';
    #     });
    #   })
    # ];
  };
}
