{ config, lib, pkgs, user, nixosConfig, ... }:
with lib;
let
  # binary paths
  grimBin = "${pkgs.grim}/bin/grim";
  lightBin = "${pkgs.light}/bin/light";
  makoctlBin = "${pkgs.mako}/bin/makoctl";
  mkdirBin = "${pkgs.coreutils}/bin/mkdir";
  notifySendBin = "${pkgs.libnotify}/bin/notify-send";
  pactlBin = "${pkgs.pulseaudio}/bin/pactl";
  pkillBin = "${pkgs.procps}/bin/pkill";
  playerctlBin = "${pkgs.playerctl}/bin/playerctl";
  py3statusBin = "${pkgs.python36Packages.py3status}/bin/py3status";
  rofiBin = "${pkgs.rofi}/bin/rofi";
  slurpBin = "${pkgs.slurp}/bin/slurp";
  swayidleBin = "${pkgs.swayidle}/bin/swayidle";
  swaylockBin = "${pkgs.swaylock}/bin/swaylock";
  swaymsgBin = "${pkgs.sway}/bin/swaymsg";
  systemctlBin = "${pkgs.systemd}/bin/systemctl";
  termiteBin = "${pkgs.termite}/bin/termite";

  i3statusDir = "${config.xdg.configHome}/i3status";
  swayDir = "${config.xdg.configHome}/sway";

  defaultWallpaper = "${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/artwork/gnome/nix-wallpaper-simple-dark-gray.png";
  screenShotDir = "$(xdg-user-dir PICTURES)/screenshots";
  screenshotPath = "${screenShotDir}/scrn-$(date +\"%Y-%m-%d-%H-%M-%S\").png";
in {
  options.local.swaywm.enable = mkEnableOption "setup sway, bar, rofi";

  config = mkIf config.local.swaywm.enable {
    #
    # SwayWM configuration
    #
    home.file."${swayDir}/config".text = ''
      ### Variables
      # Logo key. Use Mod1 for Alt.
      set $mod Mod4

      # Home row direction keys, like vim
      set $left   h
      set $leftR  Cyrillic_er
      set $down   j
      set $downR  Cyrillic_o
      set $up     k
      set $upR    Cyrillic_el
      set $right  l
      set $rightR Cyrillic_de

      ### Common colors
      set $color00 #2d2d2d
      set $color01 #393939
      set $color02 #515151
      set $color03 #747369
      set $color04 #a09f93
      set $color05 #d3d0c8
      set $color06 #e8e6df
      set $color07 #f2f0ec
      set $color08 #f2777a
      set $color09 #f99157
      set $color0A #ffcc66
      set $color0B #99cc99
      set $color0C #66cccc
      set $color0D #6699cc
      set $color0E #cc99cc
      set $color0F #d27b53

      # Wallpaper (default)
      set $wallpaper ${defaultWallpaper}

      # Include other config parts
      include ${swayDir}/config.d/*
    '';

    home.file."${swayDir}/config.d/10-systemd".text = ''
      exec "${systemctlBin} --user import-environment; ${systemctlBin} --user start sway-session.target"
    '';

    home.file."${swayDir}/config.d/10-outputs".text = ''
      # You can get the names of your outputs by running: swaymsg -t get_outputs
      ${(if nixosConfig.local.hardware.machine == "kvm" then ''
      output Virtual-1    resolution 1920x1080 position 0,0
      '' else "")}
      ${(if nixosConfig.local.hardware.machine == "alienware-15r2" then ''
      output eDP-1    resolution 1920x1080 position 0,0
      '' else "")}
      ${(if nixosConfig.networking.hostName == "knopa" then ''
      output DP-1    resolution 1920x1080 position 0,0
      output HDMI-A-1 resolution 1920x1080 position 1920,0
      '' else "")}
      ${(if nixosConfig.local.hardware.machine == "thinkpad-T430s" then ''
      output eDP-1   resolution 1600x900 position 0,0
      '' else "")}

      # Default wallpaper
      output * bg $wallpaper fill
    '';

    home.file."${swayDir}/config.d/10-inputs".text = ''
      # man 5 sway-input
      # swaymsg -t get_inputs

      input * {
        xkb_layout "us,ru"
        xkb_options "grp:win_space_toggle"

        dwt enabled
        tap enabled
        natural_scroll disabled
        middle_emulation enabled
      }
    '';

    home.file."${swayDir}/config.d/20-appearance".text = ''
      # Font for window titles.
      font pango:Hack 10

      # class                 border  backgr. text    indicat child
      client.focused          $color05 $color05 $color00 $color05 $color05
      client.focused_inactive $color01 $color01 $color05 $color03 $color01
      client.unfocused        $color01 $color00 $color05 $color01 $color01
      client.urgent           $color08 $color08 $color00 $color08 $color08


      default_border pixel 1
      default_floating_border pixel 1
      hide_edge_borders smart

      #gaps edge_gaps off
      gaps outer 0
      gaps inner 1
      smart_gaps on

      # app decoration styling
      for_window [title="^.*Mozilla\ Firefox$"] border none
      for_window [title="^.*Visual\ Studio\ Code$"] border none
      for_window [title="Calculator"] border none
      for_window [title="Image Viewer"] border none
      for_window [app_id=nautilus] border none
      for_window [app_id=eog] border none
      for_window [app_id=evince] border none
      for_window [app_id=gnome-boxes] border none
      for_window [app_id=gnome-calculator] border none
      for_window [app_id=gnome-control-center] border none
      for_window [app_id=gnome-disks] border none
      for_window [app_id=gnome-calculator] border none
      for_window [app_id=gnome-software] border none
      for_window [app_id=gnome-system-monitor] border none
      for_window [app_id=gnome-text-editor] border none
      for_window [app_id=gnome-tweaks] border none
    '';

    home.file."${swayDir}/config.d/50-basic-key-bindings".text = ''
      # kill focused window
      bindsym $mod+Shift+q               kill
      bindsym $mod+Shift+Cyrillic_shorti kill

      # Drag floating windows by holding down $mod and left mouse button.
      # Resize them with right mouse button + $mod.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating_modifier $mod normal

      # reload the configuration file
      bindsym $mod+Shift+c reload
      bindsym $mod+Shift+Cyrillic_es reload
    '';

    home.file."${swayDir}/config.d/50-moving-key-bindings".text = ''
      # Move your focus around
      bindsym $mod+$left   focus left
      bindsym $mod+$leftR  focus left
      bindsym $mod+$down   focus down
      bindsym $mod+$downR  focus down
      bindsym $mod+$up     focus up
      bindsym $mod+$upR    focus up
      bindsym $mod+$right  focus right
      bindsym $mod+$rightR focus right
      # or use $mod+[up|down|left|right]
      bindsym $mod+Left  focus left
      bindsym $mod+Down  focus down
      bindsym $mod+Up    focus up
      bindsym $mod+Right focus right

      # _move_ the focused window with the same, but add Shift
      bindsym $mod+Shift+$left   move left
      bindsym $mod+Shift+$leftR  move left
      bindsym $mod+Shift+$down   move down
      bindsym $mod+Shift+$downR  move down
      bindsym $mod+Shift+$up     move up
      bindsym $mod+Shift+$upR    move up
      bindsym $mod+Shift+$right  move right
      bindsym $mod+Shift+$rightR move right
      # ditto, with arrow keys
      bindsym $mod+Shift+Left  move left
      bindsym $mod+Shift+Down  move down
      bindsym $mod+Shift+Up    move up
      bindsym $mod+Shift+Right move right
    '';

    home.file."${swayDir}/config.d/50-layout-key-bindings".text = ''
      # You can "split" the current object of your focus with
      # $mod+b or $mod+v, for horizontal and vertical splits
      # respectively.
      bindsym $mod+b               splith;exec ${notifySendBin} 'tile horizontally' --expire-time 500
      bindsym $mod+Cyrillic_i      splith;exec ${notifySendBin} 'tile horizontally' --expire-time 500
      bindsym $mod+v               splitv;exec ${notifySendBin} 'tile vertically' --expire-time 500
      bindsym $mod+Cyrillic_em     splitv;exec ${notifySendBin} 'tile vertically' --expire-time 500
      bindsym $mod+q               split toggle
      bindsym $mod+Cyrillic_shorti split toggle

      # Switch the current container between different layout styles
      bindsym $mod+s             layout stacking
      bindsym $mod+Cyrillic_yeru layout stacking
      bindsym $mod+w             layout tabbed
      bindsym $mod+Cyrillic_tse  layout tabbed
      bindsym $mod+e             layout toggle split
      bindsym $mod+Cyrillic_u    layout toggle split

      # Make the current focus fullscreen
      bindsym $mod+f          fullscreen
      bindsym $mod+Cyrillic_a fullscreen

      # Toggle the current focus between tiling and floating mode
      bindsym $mod+Shift+space floating toggle

      # Swap focus between the tiling area and the floating area
      bindsym $mod+Ctrl+space focus mode_toggle

      # move focus to the parent container
      bindsym $mod+a           focus parent
      bindsym $mod+Cyrillic_ef focus parent
    '';

    home.file."${swayDir}/config.d/50-resizing-key-bindings".text = ''
      mode "resize" {
          # left will shrink the containers width
          # right will grow the containers width
          # up will shrink the containers height
          # down will grow the containers height
          bindsym $left   resize shrink width 10 px or 10 ppt
          bindsym $leftR  resize shrink width 10 px or 10 ppt
          bindsym $down   resize grow height 10 px or 10 ppt
          bindsym $downR  resize grow height 10 px or 10 ppt
          bindsym $up     resize shrink height 10 px or 10 ppt
          bindsym $upR    resize shrink height 10 px or 10 ppt
          bindsym $right  resize grow width 10 px or 10 ppt
          bindsym $rightR resize grow width 10 px or 10 ppt

          # ditto, with arrow keys
          bindsym Left  resize shrink width 10 px or 10 ppt
          bindsym Down  resize grow height 10 px or 10 ppt
          bindsym Up    resize shrink height 10 px or 10 ppt
          bindsym Right resize grow width 10 px or 10 ppt

          # return to default mode
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+r           mode "resize"
      bindsym $mod+Cyrillic_ka mode "resize"
    '';

    home.file."${swayDir}/config.d/50-scratchpad".text = ''
      # Sway has a "scratchpad", which is a bag of holding for windows.
      # You can send windows there and get them back later.

      # Move the currently focused window to the scratchpad
      bindsym $mod+Shift+minus move scratchpad

      # Show the next scratchpad window or hide the focused scratchpad window.
      # If there are multiple scratchpad windows, this command cycles through them.
      bindsym $mod+minus scratchpad show
    '';

    home.file."${swayDir}/config.d/50-workspaces".text = ''
      #
      # Workspaces:
      #
      set $ws1 1
      set $ws2 2
      set $ws3 3
      set $ws4 4
      set $ws5 5
      set $ws6 6
      set $ws7 7
      set $ws8 8
      set $ws9 9
      set $ws10 10:💬

      ${(if nixosConfig.networking.hostName == "knopa" then ''
      # assign workspaces to outputs
      set $leftDisplay DP-1
      set $rightDisplay HDMI-A-1
      workspace $ws1 output $leftDisplay
      workspace $ws2 output $leftDisplay
      workspace $ws3 output $leftDisplay
      workspace $ws4 output $leftDisplay
      workspace $ws5 output $leftDisplay
      workspace $ws6 output $rightDisplay
      workspace $ws7 output $rightDisplay
      workspace $ws8 output $rightDisplay
      workspace $ws9 output $rightDisplay
      workspace $ws10 output $rightDisplay
      '' else "")}

      # switch to workspace
      bindsym $mod+1 workspace $ws1
      bindsym $mod+2 workspace $ws2
      bindsym $mod+3 workspace $ws3
      bindsym $mod+4 workspace $ws4
      bindsym $mod+5 workspace $ws5
      bindsym $mod+6 workspace $ws6
      bindsym $mod+7 workspace $ws7
      bindsym $mod+8 workspace $ws8
      bindsym $mod+9 workspace $ws9
      bindsym $mod+0 workspace $ws10

      # move focused container to workspace
      bindsym $mod+Shift+1 move container to workspace $ws1
      bindsym $mod+Shift+2 move container to workspace $ws2
      bindsym $mod+Shift+3 move container to workspace $ws3
      bindsym $mod+Shift+4 move container to workspace $ws4
      bindsym $mod+Shift+5 move container to workspace $ws5
      bindsym $mod+Shift+6 move container to workspace $ws6
      bindsym $mod+Shift+7 move container to workspace $ws7
      bindsym $mod+Shift+8 move container to workspace $ws8
      bindsym $mod+Shift+9 move container to workspace $ws9
      bindsym $mod+Shift+0 move container to workspace $ws10

      # navigate workspaces next / previous
      bindsym $mod+Ctrl+Right workspace next
      bindsym $mod+Ctrl+Left  workspace prev

      # move workspace to next display
      bindsym $mod+m                 move workspace to output left
      bindsym $mod+Cyrillic_softsign move workspace to output left
      bindsym $mod+comma             move workspace to output right
      bindsym $mod+Cyrillic_be       move workspace to output right

      # bind program to workspace
      assign [title="Telegram"] $ws10
    '';

    home.file."${swayDir}/config.d/50-autolayout".text = ''
      # set floating (nontiling) for special apps
      # for_window [class="Gnome-control-center" instance="gnome-control-center"] floating enable

      # auto fullscreen
      for_window [title="feh\ .*"] fullscreen enable
      for_window [title="Media viewer"] fullscreen enable
    '';

    home.file."${swayDir}/config.d/60-terminal".text = ''
      # Your preferred terminal emulator
      set $term ${termiteBin}

      # start a terminal
      bindsym $mod+Return exec $term
      bindsym $mod+Ctrl+Return exec $term
    '';

    home.file."${swayDir}/config.d/70-rofi".text = ''
      # Your preferred application launcher
      set $menu ${rofiBin} -modi combi -show combi -combi-modi "drun,run,ssh" -show-icons -terminal $term

      # start your launcher
      bindsym $mod+d           exec $menu
      bindsym $mod+Cyrillic_ve exec $menu
    '';

    home.file."${swayDir}/config.d/70-mako".text = ''
      bindsym $mod+n exec ${makoctlBin} dismiss
      bindsym $mod+Shift+n exec ${makoctlBin} dismiss --all
    '';

    home.file."${swayDir}/config.d/70-backlight".text = ''
      bindsym --locked XF86MonBrightnessUp   exec ${lightBin} -A 3 && \
        ${notifySendBin} 'Brightness' $(light) --expire-time 200
      bindsym --locked XF86MonBrightnessDown exec ${lightBin} -U 3 && \
        ${notifySendBin} 'Brightness' $(light) --expire-time 200
    '';

    home.file."${swayDir}/config.d/70-volume".text = ''
      bindsym --locked XF86AudioMute exec --no-startup-id sh -c \
        "for s in \$(${pactlBin} list sinks short | cut -f1); do ${pactlBin} set-sink-mute \$s toggle; done" && ${pkillBin} -USR1 py3status
      bindsym --locked XF86AudioLowerVolume exec --no-startup-id \
        ${pactlBin} set-sink-volume $(${pactlBin} list sinks short | head -n 1 | cut -f1) -0.99% && \
       ${pkillBin} -USR1 py3status
      bindsym --locked XF86AudioRaiseVolume exec --no-startup-id \
        ${pactlBin} set-sink-volume $(${pactlBin} list sinks short | head -n 1 | cut -f1) +0.99% && \
       ${pkillBin} -USR1 py3status
      bindsym --locked XF86AudioMicMute exec --no-startup-id sh -c \
        "for s in \$(${pactlBin} list sources short | cut -f1); do ${pactlBin} set-source-mute \$s toggle; done" &&${pkillBin} -USR1 py3status
    '';

    home.file."${swayDir}/config.d/70-playerctl".text = ''
      bindsym --locked XF86AudioPlay exec ${playerctlBin} play
      bindsym --locked XF86AudioPause exec ${playerctlBin} pause
      bindsym --locked XF86AudioNext exec ${playerctlBin} next
      bindsym --locked XF86AudioPrev exec ${playerctlBin} previous
    '';

    home.file."${swayDir}/config.d/70-screenshots".text = ''
      # make target directory
      exec --no-startup-id ${mkdirBin} -p ${screenShotDir}
      # just make screenshot
      bindsym $mod+Print exec ${grimBin} "${screenshotPath}"
      # make screenshot of the screen area
      bindsym $mod+Shift+Print exec ${slurpBin} | ${grimBin} -g - ${screenshotPath}
    '';

    home.file."${swayDir}/config.d/99-bar".text = ''
      bar {
        status_command ${py3statusBin} -b -s -i "${config.xdg.configHome}/i3status/py3status"
        position top
        font pango:Hack 10
        separator_symbol "| "
        wrap_scroll no
        workspace_buttons yes
        strip_workspace_numbers yes
        # height

        # TODO: Tray?
        # tray {
        #   activate_button BTN_LEFT
        #   context_button BTN_RIGHT
        #   secondary_button BTN_MIDDLE
        #   tray_output all
        #   tray_padding 2
        #   icon_theme Adwaita
        # }

        colors {
          statusline $color04
          background $color00
          separator $color01
          # focused_background
          # focused_statusline
          focused_workspace   $color05 $color05 $color00
          active_workspace    $color05 $color03 $color00
          inactive_workspace  $color03 $color01 $color05
          urgent_workspace    $color08 $color08 $color00
          binding_mode        $color00 $color0A $color00
        }
      }
    '';

    home.file."${swayDir}/config.d/99-exit-menu".text = ''
      set $mode_system System: (l) lock, (e) exit, (s) suspend, (r) reboot, (S) shutdown, (R) UEFI
      mode "$mode_system" {
          bindsym l exec --no-startup-id ${swaylockBin} -i $wallpaper --scaling=fill, mode "default"
          bindsym e exit
          bindsym s exec --no-startup-id ${systemctlBin} suspend, mode "default"
          bindsym r exec --no-startup-id ${systemctlBin} reboot, mode "default"
          bindsym Shift+s exec --no-startup-id ${systemctlBin} poweroff -i, mode "default"
          bindsym Shift+r exec --no-startup-id ${systemctlBin} reboot --firmware-setup, mode "default"

          # return to default mode
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+Shift+e          mode "$mode_system"
      bindsym $mod+Shift+Cyrillic_u mode "$mode_system"
    '';

    #
    # i3status
    #
    home.file."${i3statusDir}/config".text = ''
      py3status {
        storage = '${config.xdg.cacheHome}/py3status_cache.data'
      }

      general {
        interval = 5
        colors = true
        color_good = '#ebdbb2'
        color_degraded = '#fabd2f'
        color_bad = '#fb4934'
      }

      order += 'frame music'
      frame music {
        format = '{output}{button}'
        format_separator = ' '
        format_button_closed = '♪'
        open = False
        mpris {
          format = '{state} [{artist} - ][{title}] {previous}{toggle}{next}'
          format_none = '''
        }
      }

      order += 'frame bitcoin'
      frame bitcoin {
        format = '{output}{button}'
        format_separator = ' '
        format_button_closed = ''
        open = False
        coin_market {
          format_coin = ' ''${price_usd:.0f} {percent_change_24h}%'
        }
      }

      order += 'group system'
      group system {
        button_next = 1
        button_toggle = 0
        click_mode = 'button'
        format_button_open = '↻'
        format = '{output}{button}'

        frame cpu {
          format = '{output}'
          sysdata cpu_temp {
            format = ' {cpu_temp:.0f}{temp_unit}'
            thresholds = [(50, 'good'), (70, 'degraded'), (90, 'bad')]
          }

          sysdata {
            format = '[\?min_length=4 {cpu_usage:.0f}%][\?min_length=4 {mem_used_percent:.0f}%]'
          }
        }

        frame net {
          format = '{output}'
          ${(if nixosConfig.networking.hostName == "alien" then ''
          wifi {
            format = ' {icon} {ssid}| down'
            bitrate_bad = 0
            bitrate_degraded = 0
          }
          '' else "")}

          net_rate {
            format = '{down}↓ {up}↑'
            format_value = '[\?min_length=6 {value:.1f}{unit:.1s}]'
            thresholds = [(1048576, 'bad'), (1024, 'degraded'), (0, 'good')]
          }

          whatismyip {
            colors = false
            format = '{ip} {country_iso}'
            expected = { 'country_eu': true }
            button_refresh = 1
            button_toggle = 99
          }
        }

        frame disks {
          format = '{output}'
          ${(if nixosConfig.networking.hostName == "alien" then ''
          diskdata root {
            disk = '/dev/mapper/alien--vg-root'
            format = ' {free}'
            format_space = '[\?min_length=5 {value:.1f}G]'
            separator = False
            thresholds = {'free': [(1, 'bad'), (5, 'degraded'), (10, 'good')]}
          }

          diskdata home {
            disk = '/dev/mapper/alien--vg-home'
            format = '{free}'
            format_space = '[\?min_length=5 {value:.1f}G]'
            thresholds = {'free': [(1, 'bad'), (10, 'degraded'), (20, 'good')]}
          }
          '' else "")}

          ${(if nixosConfig.networking.hostName == "knopa" then ''
          diskdata root {
            disk = '/dev/mapper/fedora-root'
            format = ' {free}'
            format_space = '[\?min_length=5 {value:.1f}G]'
            separator = False
            thresholds = {'free': [(1, 'bad'), (5, 'degraded'), (10, 'good')]}
          }

          diskdata home {
            disk = '/dev/mapper/fedora-home'
            format = '{free}'
            format_space = '[\?min_length=5 {value:.1f}G]'
            thresholds = {'free': [(1, 'bad'), (10, 'degraded'), (20, 'good')]}
          }
          '' else "")}

          diskdata io {
            format = '{total}'
            format_rate = '[\?min_length=8 {value:.1f}{unit:.1s}↕]'
          }
        }
      }

      order += 'volume_status out'
      volume_status out {
        command = 'pactl'
        channel = 'Master'
        format = ': {percentage}'
        format_muted = ': ✘ '
        volume_delta = 1
        separator = False
        cache_timeout = 1
        interval = 1
      }

      order += 'volume_status mic'
      volume_status mic {
        command = 'pactl'
        channel = 'Capture'
        format = '😮: {percentage}'
        format_muted = '😶: ✘ '
        volume_delta = 1
        is_input = True
        cache_timeout = 1
        interval = 1
      }

      ${(if nixosConfig.local.hardware.machine == "alienware-15r2" ||
        nixosConfig.local.hardware.machine == "thinkpad-T430s" then ''
      order += 'battery_level'
      battery_level {
        blocks = ""
        charging_character = ""
        format = "{icon}"
        format_notify_charging = 'Charging ({percent}%)'
        format_notify_discharging = 'Time ramaining: {time_remaining}'
        hide_seconds = True
        hide_when_full = True
        measurement_mode = 'sys'
        notify_low_level = True
        notification = True
      }
      '' else "")}

      order += 'clock'
      clock {
        format_time = " %d/%m {icon} %H:%M:%S"
      }
    '';

    #
    # rofi
    #
    programs.rofi = {
      enable = true;
      borderWidth = 1;
      colors = {
        window = {
          background = "#393939";
          border = "#393939";
          separator = "#2d2d2d";
        };
        rows = {
          normal = {
            background = "#393939";
            foreground = "#d3d0c8";
            backgroundAlt = "#393939";
            highlight = {
              background = "#393939";
              foreground = "#f2f0ec";
            };
          };
          active = {
            background = "#393939";
            foreground = "#6699cc";
            backgroundAlt = "#393939";
            highlight = {
              background = "#393939";
              foreground = "#6699cc";
            };
          };
          urgent = {
            background = "#393939";
            foreground = "#f2777a";
            backgroundAlt = "#393939";
            highlight = {
              background = "#393939";
              foreground = "#f2777a";
            };
          };
        };
      };
      extraConfig = ''
        rofi.color-enabled: true
        rofi.columns: 1
        rofi.fake-transparency: true
        rofi.fixed-num-lines: true
      '';
      font = "Hack 12";
      lines = 12;
      location = "center";
      padding = 16;
      separator = "solid";
      width = 500;
      yoffset = 0;
    };

    services.gnome-keyring = {
      enable = true;
      components = ["pkcs11" "secrets" "ssh"];
    };

    systemd.user.targets = {
      sway-session = {
        Unit = {
          Description = "sway compositor session";
          Documentation = "man:systemd.special(7)";
          BindsTo = "graphical-session.target";
          Wants = "graphical-session-pre.target";
          After = "graphical-session-pre.target";
        };
      };
    };

    systemd.user.services = {
      mako = {
        Unit = {
          Description = "A lightweight Wayland notification daemon";
          Documentation = "man:mako(1)";
          PartOf = "graphical-session.target";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.mako}/bin/mako --font 'pango:Hack 10' --markup 1";
        };
        Install = {
          WantedBy = ["sway-session.target"];
        };
      };
      swayidle = {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = "graphical-session.target";
        };
        Service = {
          Type = "simple";
          ExecStart = ''
            ${swayidleBin} -w \
              timeout 300  '${swaylockBin} -i ${defaultWallpaper} --scaling=fill -f' \
              timeout 600  '${swaymsgBin} "output * dpms off"' \
                    resume '${swaymsgBin} "output * dpms on"' \
              before-sleep '${swaylockBin} -i ${defaultWallpaper} --scaling=fill -f'
          '';
        };
        Install = {
          WantedBy = ["sway-session.target"];
        };
      };
    };
  };
}
