{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
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
  wofiBin = "${config.knopki.wofi.package}/bin/wofi";

  modifier = config.wayland.windowManager.sway.config.modifier;
  mkExecFlashNotify = msg: "exec ${notifySendBin} '${msg}' --expire-time 500";
in
{
  imports = [ ./mako.nix ./waybar.nix ];

  options.knopki.swaywm.enable = mkEnableOption "setup sway, bar, etc";

  config = mkIf config.knopki.swaywm.enable {
    home.packages = with pkgs; [
      clipman # clipboard manager
      libnotify # notify-send support
      slurp # select screen area for wf-recorder or grim
      swaylock-effects # use this instead of swaylock
      waypipe # run and and stream remote wayland app over ssh
      wdisplays # GUI outputs management
      wf-recorder # record video from display
      wl-clipboard # manipulate wayland clipboard
    ];

    programs.alacritty.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      package = null; # use system
      wrapperFeatures.gtk = true;
      config = {
        window = {
          hideEdgeBorders = "smart";
          commands = [
            {
              command = "move scratchpad, resize set width 1250 px height 1045 px, border pixel 2";
              criteria = { app_id = "telegramdesktop"; title = "^Telegram"; };
            }
            {
              command = "fullscreen enable";
              criteria = { app_id = "telegramdesktop"; title = "^Media"; };
            }
            {
              command = "floating enable, resize set width 850 px heigth 500 px";
              criteria = { app_id = "qalculate-gtk"; };
            }
          ];
        };
        floating = {
          criteria = [ ];
        };
        focus = { };
        assigns = { };
        workspaceAutoBackAndForth = true;
        modifier = "Mod4";
        bars = [ ];
        startup = [
          # set SSH_AUTH_SOCK for systemd services
          {
            command = "${systemctlBin} --user set-environment SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket) GSM_SKIP_SSH_AGENT_WORKAROUND=1";
            always = true;
          }
          {
            command = "${pkgs.gnome3.gnome-settings-daemon}/libexec/gsd-xsettings";
          }
          {
            command = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store -P";
          }
          { command = "${pkgs.dex}/bin/dex -ae Sway"; }
          { command = "${pkgs.tdesktop}/bin/telegram-desktop"; }
        ];
        gaps = {
          inner = 6;
          outer = 0;
          smartGaps = true;
          smartBorders = "no_gaps";
        };
        menu = "${wofiBin} -S drun";
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
            "${modifier}+m" = "exec ${pkgs.sway-scripts}/bin/wofi-emoj";
            "${modifier}+Shift+e" = "exec ${pkgs.sway-scripts}/bin/wofi-system-menu";
            "${modifier}+c" = "exec ${pkgs.qalculate-gtk}/bin/qalculate-gtk";
            "${modifier}+o" = mkIf config.knopki.emacs.org-capture.enable "mode org-capture";
            "${modifier}+Shift+c" = "exec ${pkgs.clipman}/bin/clipman pick -t CUSTOM -T '${wofiBin} -i -d -p Clipboard'";
          } // optionalAttrs (nixosConfig.meta.machine == "alien") {
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
        } // optionalAttrs nixosConfig.meta.tags.isKVMGuest {
          "Virtual-1" = { resolution = "1920x1080"; position = "0,0"; };
        } // optionalAttrs (nixosConfig.meta.machine == "alien") {
          "eDP-1" = { resolution = "1920x1080"; position = "0,0"; };
        } // optionalAttrs (nixosConfig.meta.machine == "oberon") {
          "DP-1" = { resolution = "1920x1080"; position = "0,0"; };
          "HDMI-A-1" = { resolution = "1920x1080"; position = "1920,0"; };
        } // optionalAttrs (nixosConfig.meta.machine == "t430s") {
          "eDP-1" = { resolution = "1600x900"; position = "0,0"; };
        };
        modes = mkOptionDefault {
          org-capture =
            let
              wlPasteBin = "${pkgs.wl-clipboard}/bin/wl-paste";
              orgCaptureBin = "${config.knopki.emacs.org-capture.package}/bin/doom-org-capture";
            in
            mkIf config.knopki.emacs.org-capture.enable {
              t = "exec ${wlPasteBin} | ${orgCaptureBin} -k t, mode default";
              n = "exec ${wlPasteBin} | ${orgCaptureBin} -k n, mode default";
              Escape = "mode default";
            };
        };
      };
      extraConfig = ''
        # hide cursor on idle
        seat * hide_cursor 8000
      '';
    };

    xdg.configFile."sway/config.d/oberon.conf" = mkIf (nixosConfig.meta.machine == "oberon") {
      text =
        let
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
        Install = { WantedBy = [ "sway-session.target" ]; };
      };

      # change opacity of unfocused windows
      sway-inactive-windows-transparency = {
        Unit = {
          Description = "Set opacity of onfocused windows in SwayWM";
          PartOf = "graphical-session.target";
          StartLimitIntervalSec = "0";
        };
        Service = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.sway-contrib.inactive-windows-transparency}/bin/inactive-windows-transparency.py -o 0.9
          '';
          Restart = "on-failure";
          RestartSec = "1";
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
    };

    # Network Manager applet with appindicator in tray
    services.network-manager-applet.enable = true;
    xsession.preferStatusNotifierItems = true;

    # Wofi
    knopki.wofi = {
      enable = true;
      width = "40%";
      term = mkIf config.programs.alacritty.enable
        "${config.programs.alacritty.package}/bin/alacritty -e";
      allow_images = true;
      allow_markup = true;
      parse_search = true;
      no_actions = true;
      key_up = "Alt_L-k";
      key_down = "Alt_L-j";
      stylesheet = builtins.readFile ./wofi.css;
    };
  };
}
