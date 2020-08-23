{ config, lib, pkgs, ... }:
let
  inherit (lib) mkBefore mkDefault mkIf;
  isGnome = config.services.xserver.desktopManager.gnome3.enable || config.programs.sway.enable;
in
{
  imports = [];

  boot = {
    optimizeForWorkstation = true;
    supportedFilesystems = [ "ntfs" ];
  };

  environment = {
    gnome3.excludePackages = with pkgs.gnome3; [
      epiphany
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-music
      gnome-photos
      gnome-screenshot
      gnome-software
      gnome-weather
      totem
      yelp
    ];

    sessionVariables = {
      XDF_CURRENT_DESKTOP = mkIf isGnome "GNOME:Unity";
    };

    systemPackages = with pkgs; [
      anki
      blender
      borgbackup
      cachix
      darktable
      dive
      feh
      gimp
      gnome3.dconf-editor
      gnupg
      google-cloud-sdk
      graphviz
      keepassxc
      keybase-gui
      krita
      kubectl
      kubernetes-helm
      libreoffice
      mpv
      nix-du
      nix-index
      nix-prefetch-git
      nixpkgs-fmt
      nmap-graphical
      nodejs
      openssh
      pavucontrol
      picard
      pinentry-gnome
      playerctl
      postman
      powertop
      qt5.qtwayland
      qt5ct
      remmina
      shfmt
      skypeforlinux
      spotify
      tdesktop
      tor-browser-bundle-bin
      transmission-gtk
      virtmanager
      winbox-bin
      xdg_utils
      yarn
      youtube-dl
    ];
  };

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      emojione
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      fira-code-symbols
      font-awesome_4
      noto-fonts
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" "EmojiOne Color" ];
        monospace = [ "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
      localConf = ''
        <?xml version="1.0" ?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <!-- there we fix huge icons -->
          <match target="scan">
            <test name="family">
              <string>Noto Color Emoji</string>
            </test>
            <edit name="scalable" mode="assign">
              <bool>false</bool>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };


  hardware = {
    pulseaudio = {
      enable = mkDefault true;
      support32Bit = mkDefault true;
    };

    sane = {
      enable = mkDefault true;
      extraBackends = [];
    };
  };

  meta.tags.isWorkstation = true;

  networking = {
    firewall = {
      interfaces.docker0 = {
        allowedUDPPortRanges = [ { from = 1; to = 65535; } ];
        allowedTCPPortRanges = [ { from = 1; to = 65535; } ];
      };
    };
    networkmanager.enable = true;
  };

  nix = {
    extraOptions = mkBefore ''
      keep-derivations = true
      keep-env-derivations = true
      keep-outputs = true
    '';
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = mkIf config.services.gnome3.gnome-keyring.enable "gnome3";
    };
    light.enable = true;
    sway = {
      enable = true;
      extraOptions = [ "--my-next-gpu-wont-be-nvidia" ];
      extraPackages = with pkgs; [
        alacritty
        dex
        swaybg
        swayidle
        swaylock
        waypipe
        wdisplays
        xwayland
      ];
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export XDG_SESSION_TYPE=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_QPA_PLATFORMTHEME=qt5ct
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      wrapperFeatures.gtk = true;
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
    };
    dbus.packages = with pkgs; [ gnome3.dconf ];
    earlyoom.enable = true;
    flatpak.enable = true;
    fwupd.enable = true;
    gnome3 = {
      core-os-services.enable = true;
      core-shell.enable = true;
      core-utilities.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      gnome-remote-desktop.enable = true;
      gnome-settings-daemon.enable = true;
    };
    gvfs.enable = true;
    locate = {
      enable = true;
      localuser = null;
      locate = pkgs.mlocate;
      pruneBindMounts = true;
    };
    keybase.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [ cups-kyocera gutenprint ];
    };
    trezord.enable = true;
    xserver = {
      enable = true;
      desktopManager.gnome3.enable = true;
      displayManager.gdm = {
        enable = true;
        #wayland = false;
      };
      layout = "us,ru";
      libinput = {
        enable = true;
        sendEventsMode = "disabled-on-external-mouse";
        middleEmulation = false;
        naturalScrolling = true;
      };
      xkbOptions = "grp:caps_toggle,grp_led:caps";
    };
  };

  virtualisation = {
    libvirtd.enable = true;
    docker = {
      autoPrune.dates = mkDefault "weekly";
      autoPrune.enable = mkDefault true;
      enable = mkDefault true;
      enableOnBoot = mkDefault true;
      liveRestore = mkDefault true;
    };
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}
