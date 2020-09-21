{ config, lib, pkgs, ... }:
with lib;
let
  theme = {
    base00 = "#282c34";
    base01 = "#353b45";
    base02 = "#3e4451";
    base03 = "#545862";
    base04 = "#565c64";
    base05 = "#abb2bf";
    base06 = "#b6bdca";
    base07 = "#c8ccd4";
    base08 = "#e06c75";
    base09 = "#d19a66";
    base0A = "#e5c07b";
    base0B = "#98c379";
    base0C = "#56b6c2";
    base0D = "#61afef";
    base0E = "#c678dd";
    base0F = "#be5046";
  };
  defaultWallpaper =
    "${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/artwork/gnome/nix-wallpaper-simple-dark-gray.png";

  # binary paths
  alacrittyBin = "${pkgs.alacritty}/bin/alacritty";
  lightBin = "${pkgs.light}/bin/light";
  makoctlBin = "${pkgs.mako}/bin/makoctl";
  notifySendBin = "${pkgs.libnotify}/bin/notify-send";
  pactlBin = "${pkgs.pulseaudio}/bin/pactl";
  playerctlBin = "${pkgs.playerctl}/bin/playerctl";
  swaymsgBin = "${pkgs.sway}/bin/swaymsg";
  systemctlBin = "${pkgs.systemd}/bin/systemctl";
  swaylockCmd = "${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --clock --effect-vignette 0.5:0.5 --effect-pixelate 24";

  rofiAppMenuCmd = "${pkgs.rofi}/bin/rofi -modi 'run,drun' -show-icons -theme-str 'element-icon { size: 2.3ch;}'";

  modifier = config.wayland.windowManager.sway.config.modifier;
  mkExecFlashNotify = msg: "exec ${notifySendBin} '${msg}' --expire-time 500";
in
{
  imports = [ ./mako.nix ./rofi.nix ./waybar.nix ];

  options.knopki.swaywm.enable = mkEnableOption "setup sway, bar, etc";

  config = mkIf config.knopki.swaywm.enable {
    home.packages = with pkgs; [
      libnotify # notify-send support
      networkmanager_dmenu # connect to some connection
      networkmanagerapplet # GUT network setting
      swaylock-effects # use this instead of swaylock
      waypipe # run and and stream remote wayland app over ssh
      wdisplays # GUI outputs management
      wf-recorder # record video from display
      wl-clipboard # manipulate wayland clipboard 
    ];

    knopki.alacritty.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      package = null; # use system
      config = {
        fonts = [ "Noto Sans 12" ];
        window = {
          hideEdgeBorders = "smart";
          commands = [
            {
              command = "move scratchpad, resize set width 1250 px height 1045 px";
              criteria = { app_id = "telegramdesktop"; title = "^Telegram"; };
            }
            {
              command = "fullscreen enable";
              criteria = { app_id = "telegramdesktop"; title = "^Media"; };
            }
          ];
        };
        floating = {
          criteria = [];
        };
        focus = {};
        assigns = {};
        workspaceAutoBackAndForth = true;
        modifier = "Mod4";
        colors = {
          background = theme.base07;
          focused = {
            border = theme.base05;
            background = theme.base0D;
            text = theme.base00;
            indicator = theme.base0D;
            childBorder = theme.base0D;
          };
          focusedInactive = {
            border = theme.base01;
            background = theme.base01;
            text = theme.base05;
            indicator = theme.base03;
            childBorder = theme.base01;
          };
          unfocused = {
            border = theme.base01;
            background = theme.base00;
            text = theme.base05;
            indicator = theme.base01;
            childBorder = theme.base01;
          };
          urgent = {
            border = theme.base08;
            background = theme.base08;
            text = theme.base00;
            indicator = theme.base08;
            childBorder = theme.base08;
          };
          placeholder = {
            border = theme.base00;
            background = theme.base00;
            text = theme.base05;
            indicator = theme.base00;
            childBorder = theme.base00;
          };
        };
        bars = [];
        startup = [
          # set SSH_AUTH_SOCK for systemd services
          {
            command = "${systemctlBin} --user set-environment SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)";
            always = true;
          }
          {
            command = "${systemctlBin} --user import-environment HOME I3SOCK PATH SWAYSOCK USER WAYLAND_DISPLAY; ${systemctlBin} --user start sway-session.target";
          }
          {
            command = "${pkgs.sway-scripts}/bin/import-gsettings gtk-theme:gtk-theme-name icon-theme:gtk-icon-theme-name cursor-theme:gtk-cursor-theme-name";
            always = true;
          }
          { command = "${pkgs.dex}/bin/dex -ae Sway"; }
          { command = "${pkgs.tdesktop}/bin/telegram-desktop"; }
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        ];
        gaps = {
          inner = 6;
          outer = 0;
          smartGaps = true;
          smartBorders = "no_gaps";
        };
        menu = "${rofiAppMenuCmd} -show drun";
        terminal = alacrittyBin;
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

            "${modifier}+shift+d" = "exec ${rofiAppMenuCmd} -show run";

            "Mod1+Tab" = "exec ${pkgs.sway-scripts}/bin/rofi-window-switcher";

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

            "Print" = "exec ${pkgs.sway-scripts}/bin/rofi-screenshot-menu \"${config.xdg.userDirs.pictures}/screenshots\"";
            "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";
            "${modifier}+p" = "exec ${pkgs.sway-scripts}/bin/rofi-pass";
            "${modifier}+o" = "exec ${pkgs.rofi}/bin/rofi -modi emoji -show emoji";
            "${modifier}+Shift+e" = "exec ${pkgs.sway-scripts}/bin/rofi-system-menu";
            "${modifier}+c" = "exec ${pkgs.rofi}/bin/rofi -modi calc -show calc -no-show-match -no-sort > /dev/null";
          } // optionalAttrs (config.meta.machine == "alien") {
            "XF86TouchpadToggle" = "input type:touchpad events toggle enabled disabled";
            # More Alienware keys: XF86KbdLightOnOff, XF86KbdLightOnOff, XF86Tools, XF86Launch5-9
          }
        );
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
        output = {
          "*" = { bg = "${defaultWallpaper} fill"; };
        } // optionalAttrs config.meta.tags.isKVMGuest {
          "Virtual-1" = { resolution = "1920x1080"; position = "0,0"; };
        } // optionalAttrs (config.meta.machine == "alien") {
          "eDP-1" = { resolution = "1920x1080"; position = "0,0"; };
        } // optionalAttrs (config.meta.machine == "oberon") {
          "DP-1" = { resolution = "1920x1080"; position = "0,0"; };
          "HDMI-A-1" = { resolution = "1920x1080"; position = "1920,0"; };
        } // optionalAttrs (config.meta.machine == "t430s") {
          "eDP-1" = { resolution = "1600x900"; position = "0,0"; };
        };
        modes = mkOptionDefault {};
      };
      extraConfig = ''
        # hide cursor on idle
        seat * hide_cursor 8000

        # Include other config parts
        include ${config.xdg.configHome}/sway/config.d/*
      '';
    };

    xdg.configFile."sway/config.d/oberon.conf" = mkIf (config.meta.machine == "oberon") {
      text = let
        leftDisplay = "DP-1";
        rightDisplay = "HDMI-A-1";
      in
        ''
          workspace 1 output ${leftDisplay}
          workspace 2 output ${leftDisplay}
          workspace 3 output ${leftDisplay}
          workspace 4 output ${leftDisplay}
          workspace 5 output ${leftDisplay}
          workspace 6 output ${rightDisplay}
          workspace 7 output ${rightDisplay}
          workspace 8 output ${rightDisplay}
          workspace 9 output ${rightDisplay}
          workspace 10 output ${rightDisplay}
        '';
    };

    systemd.user.services = {
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
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
      sway-inactive-windows-transparency = {
        Unit = {
          Description = "Set opacity of onfocused windows in SwayWM";
          PartOf = "graphical-session.target";
          StartLimitIntervalSec = "0";
        };
        Service = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.sway-inactive-windows-transparency}/bin/inactive-windows-transparency.py -o 0.9
          '';
          Restart = "on-failure";
          RestartSec = "1";
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
    };

    xdg.configFile = {
      "networkmanager-dmenu/config.ini".text = generators.toINI {} {
        dmenu = {
          dmenu_command = "${pkgs.rofi}/bin/rofi";
          pinentry = "${pkgs.pinentry-gnome}/bin/pinentry-gnome3";
          rofi_highlight = "True";
          wifi_chars = "▂▄▆█";
          list_saved = "True";
        };
        dmenu_passphrase = { rofi_obscure = "True"; };
        editor = { terminal = alacrittyBin; gui_if_available = "True"; };
      };
    };
  };
}
