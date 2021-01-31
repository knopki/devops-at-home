{ config, lib, pkgs, ... }:
with lib;
let
  isGnome = config.services.xserver.desktopManager.gnome3.enable || config.programs.sway.enable;
in
{
  imports = [ ];

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

    systemPackages = with pkgs; [
      anki
      asciinema
      blender
      cachix
      darktable
      dive
      gimp
      gnome3.dconf-editor
      gnupg
      google-cloud-sdk
      graphviz
      keepassxc
      krita
      kubectl
      kubernetes-helm
      libreoffice
      mindustry
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
      remmina
      rmlint
      shfmt
      skypeforlinux
      spotify
      tdesktop
      tor-browser-bundle-bin
      qalculate-gtk
      transmission-gtk
      virtmanager
      winbox-bin
      xdg_utils
      yarn
      youtube-dl
    ];
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts
      font-awesome_4
      noto-fonts
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
      localConf = ''
        <?xml version="1.0" ?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <!-- This adds Noto Color Emoji as a final fallback font for the default font families. -->
          <match>
            <test name="family"><string>sans-serif</string></test>
            <edit name="family" mode="prepend" binding="weak">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <match>
            <test name="family"><string>serif</string></test>
            <edit name="family" mode="prepend" binding="weak">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <!-- Use Noto Color Emoji when other popular fonts are being specifically requested. -->
          <match target="pattern">
              <test qual="any" name="family"><string>Apple Color Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Android Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Twitter Color Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Twemoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Twemoji Mozilla</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>TwemojiMozilla</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>EmojiTwo</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Emoji Two</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>EmojiSymbols</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Symbola</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
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
      extraBackends = [ ];
    };
  };

  meta.tags.isWorkstation = true;

  networking = {
    firewall = {
      checkReversePath = mkDefault "loose";
      interfaces =
        let
          # trust at least local docker interfaces
          trustInterfaces = [ "docker0" "br_xod_default" ];
          allowedAllPortRanges = genAttrs
            [ "allowedUDPPortRanges" "allowedTCPPortRanges" ]
            (name: [{ from = 1; to = 65535; }]);
        in
        (genAttrs trustInterfaces (name: allowedAllPortRanges));
    };
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
    useNetworkd = true;
    wireguard.enable = true;
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
    geary.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    light.enable = true;
    sway = {
      enable = true;
      extraOptions = [ "--my-next-gpu-wont-be-nvidia" ];
      extraPackages = with pkgs; [
        qt5.qtwayland # enable Qt5 Wayland support
        swaybg # set wallpaper (very simple)
        swayidle
        swaylock
        xwayland
      ];
      extraSessionCommands = ''
        source /etc/profile
        test -f $HOME/.profile && source $HOME/.profile

        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        export MOZ_DBUS_REMOTE=1

        systemctl --user import-environment
      '';
      wrapperFeatures.gtk = true;
    };
    qt5ct.enable = true;
  };

  security.protectKernelImage = false;

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
    printing = {
      enable = true;
      drivers = with pkgs; [ cups-kyocera gutenprint ];
    };
    resolved.enable = true;
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
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
  };
}
