{ pkgs, lib, config, username, ...}:
let
  selfHM = config.home-manager.users."${username}";
  i3statusDir = "${selfHM.xdg.configHome}/i3status";
  # rofiDir = "${selfHM.xdg.configHome}/rofi";
  swayDir = "${selfHM.xdg.configHome}/sway";
in with builtins; {
  home.file."${i3statusDir}/config".text = ''
    py3status {
      storage = '${selfHM.xdg.cacheHome}/py3status_cache.data'
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
        format_none = ''''
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
        ${(if config.networking.hostName == "alien" then ''
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
        ${(if config.networking.hostName == "alien" then ''
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

        ${(if config.networking.hostName == "knopa" then ''
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

    ${(if config.networking.hostName == "alien" then ''
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

  home.file."${swayDir}/config".text = ''
    # Read `man 5 sway` for a complete reference.

    ### Variables
    #
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
    #
    set $base00 #2d2d2d
    set $base01 #393939
    set $base02 #515151
    set $base03 #747369
    set $base04 #a09f93
    set $base05 #d3d0c8
    set $base06 #e8e6df
    set $base07 #f2f0ec
    set $base08 #f2777a
    set $base09 #f99157
    set $base0A #ffcc66
    set $base0B #99cc99
    set $base0C #66cccc
    set $base0D #6699cc
    set $base0E #cc99cc
    set $base0F #d27b53

    ### Key bindings
    #
    # Basics:
    #

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

    # exit sway (logs you out of your wayland session)
    set $swaynagexit swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
    bindsym $mod+Shift+e          exec $swaynagexit
    bindsym $mod+Shift+Cyrillic_u exec $swaynagexit

    #
    # Moving around:
    #
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

    ${(if config.networking.hostName == "knopa" then ''
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

    #
    # Layout stuff:
    #
    # You can "split" the current object of your focus with
    # $mod+b or $mod+v, for horizontal and vertical splits
    # respectively.
    bindsym $mod+b               splith;exec notify-send 'tile horizontally' --expire-time 500
    bindsym $mod+Cyrillic_i      splith;exec notify-send 'tile horizontally' --expire-time 500
    bindsym $mod+v               splitv;exec notify-send 'tile vertically' --expire-time 500
    bindsym $mod+Cyrillic_em     splitv;exec notify-send 'tile vertically' --expire-time 500
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

    # move workspace to next display
    bindsym $mod+m                 move workspace to output left
    bindsym $mod+Cyrillic_softsign move workspace to output left
    bindsym $mod+comma             move workspace to output right
    bindsym $mod+Cyrillic_be       move workspace to output right

    #
    # Scratchpad:
    #
    # Sway has a "scratchpad", which is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    bindsym $mod+Shift+minus move scratchpad

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym $mod+minus scratchpad show

    #
    # Resizing containers:
    #
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

    # Include other config parts
    include ${swayDir}/config.d/*
  '';

  home.file."${swayDir}/config.d/programs".text = ''
    # Your preferred terminal emulator
    set $term termite -d "$(cat /tmp/$USER-pwd || echo $HOME)"

    # Your preferred application launcher
    set $menu rofi -modi combi -show combi -combi-modi "drun,run,ssh" -show-icons -terminal $term

    # start a terminal
    bindsym $mod+Return exec $term

    # start your launcher
    bindsym $mod+d           exec $menu
    bindsym $mod+Cyrillic_ve exec $menu

    # lock session
    # TODO: add wallpaper
    # set $swaylock swaylock -i {{ wallpaper }} --scaling=fill
    set $swaylock swaylock
    bindsym Ctrl+Alt+l           exec $swaylock
    bindsym Ctrl+Alt+Cyrillic_de exec $swaylock


    # bind program to workspace
    assign [title="Telegram"] $ws10

    # set floating (nontiling) for special apps
    # for_window [class="Gnome-control-center" instance="gnome-control-center"] floating enable

    # auto fullscreen
    for_window [title="feh\ .*"] fullscreen enable
    for_window [title="Media viewer"] fullscreen enable

    #
    # autorstart
    #
    # lock on idle and sleep TODO: add wallpaper
    exec --no-startup-id swayidle \
      timeout 600 'swaylock' \
      timeout 1200 'swaymsg "output * dpms off"' \
      resume 'swaymsg "output * dpms on"' \
      before-sleep 'swaylock --scaling=fill'

    # notification daemon
    exec --no-startup-id /usr/bin/mako --font 'pango:Hack Nerd Font 10' --markup 1

    # ssh/gpg agent
    # TODO: enable or delete
    #exec --no-startup-id sh -c "echo '''' | /usr/bin/gnome-keyring-daemon -r --components='gpg,pkcs11,secrets,ssh' --unlock"
  '';

  home.file."${swayDir}/config.d/output".text = ''
    # You can get the names of your outputs by running: swaymsg -t get_outputs
    ${(if config.networking.hostName == "alien" then ''
    output eDP-1    resolution 1920x1080 position 0,0
    '' else "")}
    ${(if config.networking.hostName == "knopa" then ''
    output DP-1    resolution 1920x1080 position 0,0
    output HDMI-A-1 resolution 1920x1080 position 1920,0
    '' else "")}

    # Default wallpaper
    # TODO: add wallpaper
    # output * bg {{ wallpaper }} fill
  '';

  home.file."${swayDir}/config.d/media-keys".text = ''
    # Backlight
    bindsym XF86MonBrightnessUp   exec light -A 3 && notify-send 'Brightness' $(light) --expire-time 200
    bindsym XF86MonBrightnessDown exec light -U 3 && notify-send 'Brightness' $(light) --expire-time 200

    # Volume
    bindsym XF86AudioMute exec --no-startup-id sh -c "for s in \$(pactl list sinks short | cut -f1); do pactl set-sink-mute \$s toggle; done"  && pkill -USR1 py3status
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume $(pactl list sinks short | head -n 1 | cut -f1) -1% && pkill -USR1 py3status
    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume $(pactl list sinks short | head -n 1 | cut -f1) +1% && pkill -USR1 py3status

    # Media player controls
    bindsym XF86AudioPlay exec playerctl play
    bindsym XF86AudioPause exec playerctl pause
    bindsym XF86AudioNext exec playerctl next
    bindsym XF86AudioPrev exec playerctl previous

    # Screenshots
    bindsym $mod+Print        exec grim $(xdg-user-dir PICTURES)/$(date +'%Y-%m-%d-%H%M%S_grim.png')
    bindsym $mod+Shift+Print  exec slurp | grim -g - $(xdg-user-dir PICTURES)/$(date +'%Y-%m-%d-%H%M%S_grim.png')
  '';

  home.file."${swayDir}/config.d/input".text = ''
    # man 5 sway-input
    # swaymsg -t get_inputs

    ${(if config.networking.hostName == "alien" then ''
    input "2:7:SynPS/2_Synaptics_TouchPad" {
      dwt enabled
      tap enabled
      natural_scroll disabled
      middle_emulation enabled
    }
    '' else "")}

    ${(if config.networking.hostName == "knopa" then ''
    input "6127:24647:Lenovo_ThinkPad_Compact_USB_Keyboard_with_TrackPoint" {
      dwt enabled
      tap enabled
      natural_scroll disabled
      middle_emulation enabled
    }
    input "7119:5:USB_Optical_Mouse" {
      dwt enabled
      tap enabled
      natural_scroll disabled
      middle_emulation enabled
    }
    '' else "")}
  '';

  home.file."${swayDir}/config.d/bar".text = ''
    # Read `man 5 sway-bar` for more information about this section.

    bar {
      status_command py3status -b -s -i "${selfHM.xdg.configHome}/i3status/py3status"
      position top
      font pango:Hack Nerd Font 10
      separator_symbol "| "
      wrap_scroll no
      workspace_buttons yes
      strip_workspace_numbers yes
      # height

      # tray {
      #   activate_button BTN_LEFT
      #   context_button BTN_RIGHT
      #   secondary_button BTN_MIDDLE
      #   tray_output all
      #   tray_padding 2
      #   icon_theme Adwaita
      # }

      colors {
        statusline $base04
        background $base00
        separator $base01
        # focused_background
        # focused_statusline
        focused_workspace   $base05 $base05 $base00
        active_workspace    $base05 $base03 $base00
        inactive_workspace  $base03 $base01 $base05
        urgent_workspace    $base08 $base08 $base00
        binding_mode        $base00 $base0A $base00
      }
    }
  '';

  home.file."${swayDir}/config.d/appearance".text = ''
    # Font for window titles.
    font pango:Hack Nerd Font 10

    # class                 border  backgr. text    indicat child
    client.focused          $base05 $base05 $base00 $base05 $base05
    client.focused_inactive $base01 $base01 $base05 $base03 $base01
    client.unfocused        $base01 $base00 $base05 $base01 $base01
    client.urgent           $base08 $base08 $base00 $base08 $base08


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
    font = "Hack Nerd Font 12";
    lines = 12;
    location = "center";
    padding = 16;
    separator = "solid";
    width = 500;
    yoffset = 0;
  };
}
