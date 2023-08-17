{
  config,
  lib,
  pkgs,
  nixosConfig,
  ...
}: let
  inherit (lib) mkAfter mkIf mkOptionDefault optionalAttrs hasAttr;

  defaultWallpaper = "${pkgs.nixos-artwork.wallpapers.dracula}/share/backgrounds/nixos/nix-wallpaper-dracula.png";

  # binary paths
  alacrittyBin = "${config.programs.alacritty.package}/bin/alacritty";
  lightBin = "${pkgs.light}/bin/light";
  makoctlBin = "${pkgs.mako}/bin/makoctl";
  notifySendBin = "${pkgs.libnotify}/bin/notify-send";
  pactlBin = "${pkgs.pulseaudio}/bin/pactl";
  playerctlBin = "${config.services.playerctld.package}/bin/playerctl";
  swaymsgBin = "${pkgs.sway}/bin/swaymsg";
  swaylockCmd = "${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --clock --effect-vignette 0.5:0.5 --effect-pixelate 24";
  systemctlBin = "${pkgs.systemd}/bin/systemctl";
  wofiBin = "${config.programs.wofi.package}/bin/wofi";

  modifier = config.wayland.windowManager.sway.config.modifier;
  mkExecFlashNotify = msg: "exec ${notifySendBin} '${msg}' --expire-time 500";

  window = {
    hideEdgeBorders = "smart";
    commands = [
      {
        command = "move scratchpad, resize set width 1250 px height 1045 px, border pixel 2";
        criteria = {
          app_id = "telegramdesktop";
          title = "^Telegram";
        };
      }
      {
        command = "fullscreen enable";
        criteria = {
          app_id = "telegramdesktop";
          title = "^Media";
        };
      }
      {
        command = "floating enable, resize set width 850 px heigth 500 px";
        criteria = {app_id = "qalculate-gtk";};
      }
    ];
  };

  startup = [
    # NOTE: Slow launch for (some) GTK apps https://github.com/swaywm/sway/issues/5732
    {
      command = "${systemctlBin} --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK DBUS_SESSION_BUS_ADDRESS XAUTHORITY";
      always = true;
    }
    {
      command = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK DBUS_SESSION_BUS_ADDRESS XAUTHORITY";
      always = true;
    }
    # set SSH_AUTH_SOCK for systemd services
    {
      command = "${systemctlBin} --user set-environment SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket) GSM_SKIP_SSH_AGENT_WORKAROUND=1";
      always = true;
    }
    # policy kit agent
    {command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";}
    # clipboard history
    {command = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store -P";}
    # autorun of apps
    {command = "${pkgs.dex}/bin/dex -ae Sway";}
    # telegram is must
    {command = "${pkgs.tdesktop}/bin/telegram-desktop";}
  ];

  keybindings = mkOptionDefault (
    {
      # remove conflicting defaults
      "${modifier}+space" = mkAfter null;

      "${modifier}+b" = "splith;${mkExecFlashNotify "tile horizontally"}";
      "${modifier}+v" = "splitv;${mkExecFlashNotify "tile vertically"}";
      "${modifier}+q" = "split toggle";

      "${modifier}+0" = "workspace number 10";
      "${modifier}+shift+0" = "move container to workspace number 10";
      "${modifier}+comma" = "move workspace to output left";
      "${modifier}+period" = "move workspace to output right";

      "${modifier}+shift+f" = "focus mode_toggle";

      "${modifier}+shift+d" = "exec ${wofiBin} -S run";

      "Mod1+Tab" = "exec ${pkgs.sway-scripts}/bin/wofi-window-switcher";

      "${modifier}+n" = "exec ${makoctlBin} dismiss";
      "${modifier}+Shift+n" = "exec ${makoctlBin} dismiss --all";

      "XF86MonBrightnessUp" = "exec ${lightBin} -A 3";
      "XF86MonBrightnessDown" = "exec ${lightBin} -U 3";

      "--locked XF86AudioLowerVolume" = "exec ${pactlBin} set-sink-volume @DEFAULT_SINK@ -0.99%";
      "--locked XF86AudioRaiseVolume" = "exec ${pactlBin} set-sink-volume @DEFAULT_SINK@ +0.99%";
      "--locked XF86AudioMicMute" = "exec ${pactlBin} set-source-mute @DEFAULT_SOURCE@ toggle";
      "--locked XF86AudioMute" = "exec ${pactlBin} set-sink-mute @DEFAULT_SINK@ toggle";
      "--locked XF86AudioPlay" = "exec ${playerctlBin} play-pause";
      "--locked XF86AudioNext" = "exec ${playerctlBin} next";
      "--locked XF86AudioPrev" = "exec ${playerctlBin} previous";

      "Print" = "exec ${pkgs.sway-scripts}/bin/wofi-screenshot-menu \"${config.xdg.userDirs.pictures}/screenshots\"";
      "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";
      "${modifier}+p" = "exec ${pkgs.sway-scripts}/bin/wofi-pass";
      "${modifier}+Shift+e" = "exec ${pkgs.sway-scripts}/bin/wofi-system-menu";
      "${modifier}+c" = "exec ${pkgs.qalculate-gtk}/bin/qalculate-gtk";
      "${modifier}+o" = mkIf (hasAttr "org-capture" config.wayland.windowManager.sway.config.modes) "mode org-capture";
      "${modifier}+Shift+c" = "exec ${pkgs.clipman}/bin/clipman pick -t CUSTOM -T '${wofiBin} -i -d -p Clipboard'";
    }
    // optionalAttrs (nixosConfig.networking.hostName == "alien") {
      # More Alienware keys: XF86KbdLightOnOff, XF86KbdLightOnOff, XF86Tools, XF86Launch5-9
      "XF86TouchpadToggle" = "input type:touchpad events toggle enabled disabled";
    }
  );
in {
  imports = [
    ./mako.nix
    ./sway-inactive-windows-transparency.nix
    ./waybar.nix
    ./wofi.nix
  ];

  services.playerctld.enable = true;

  # Network Manager applet with appindicator in tray
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;

  home.packages = with pkgs; [
    clipman # clipboard manager
    libnotify # notify-send support
    slurp # select screen area for wf-recorder or grim
    sway-scripts
    swaylock-effects # use this instead of swaylock
    waypipe # run and and stream remote wayland app over ssh
    wdisplays # GUI outputs management
    wf-recorder # record video from display
    wl-clipboard # manipulate wayland clipboard
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null; # use system
    wrapperFeatures.gtk = true;
    config = {
      inherit window startup keybindings;
      floating = {
        criteria = [];
      };
      focus = {};
      assigns = {};
      modifier = "Mod4";
      bars = [];
      gaps = {
        inner = 6;
        outer = 0;
        smartGaps = true;
        smartBorders = "no_gaps";
      };
      menu = "${wofiBin} -S drun";
      terminal = alacrittyBin;
      bindkeysToCode = true;
      input = {
        "type:keyboard" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:win_space_toggle";
        };
        "type:touchpad" = {
          tap = "enabled";
          dwt = "enabled";
          middle_emulation = "enabled";
          natural_scroll = "enabled";
        };
      };
      output =
        {
          "*" = {bg = "${defaultWallpaper} fill";};
        }
        // optionalAttrs (nixosConfig.networking.hostName == "alien") {
          "eDP-1" = {
            resolution = "1920x1080";
            position = "0,0";
          };
        }
        // optionalAttrs (nixosConfig.networking.hostName == "panzer") {
          "eDP-1" = {
            resolution = "1600x900";
            position = "0,0";
          };
        };
    };
    extraConfig = ''
      # hide cursor on idle
      seat * hide_cursor 8000
    '';
  };

  # xdg.configFile."sway/config.d/alien.conf" = mkIf (nixosConfig.networking.hostName == "alien") {
  #   text =
  #     let
  #       leftDisplay = "DP-1";
  #       rightDisplay = "HDMI-A-1";
  #     in
  #     ''
  #     '';
  # };

  systemd.user.services = {
    # lock screen on idle
    swayidle = {
      Unit = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = "graphical-session.target";
        StartLimitIntervalSec = "0";
      };
      Service = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout 600  '${swaylockCmd} --grace 2 --fade-in 2' \
            resume       '${swaymsgBin} "output * dpms on"' \
            before-sleep '${playerctlBin} pause -a || true && \
                          ${pactlBin} set-sink-mute @DEFAULT_SINK@ 1 || true && \
                          ${swaylockCmd}' \
            lock         '${swaylockCmd} --fade-in 2'
        '';
        Restart = "on-failure";
        RestartSec = "1";
      };
      Install = {WantedBy = ["sway-session.target"];};
    };
  };
}
