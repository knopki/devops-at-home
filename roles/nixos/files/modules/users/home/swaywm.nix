{ config, lib, pkgs, user, nixosConfig, ... }:
with lib;
let
  defaultWallpaper =
    "${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/artwork/gnome/nix-wallpaper-simple-dark-gray.png";
  screenShotDir = "$(xdg-user-dir PICTURES)/screenshots";
  screenshotPath = ''${screenShotDir}/scrn-$(date +"%Y-%m-%d-%H-%M-%S").png'';
  swayDir = "${config.xdg.configHome}/sway";

  # binary paths
  alacrittyBin = "${pkgs.alacritty}/bin/alacritty";
  bashBin = "${pkgs.bashInteractive}/bin/bash";
  fzfBin = "${pkgs.fzf}/bin/fzf";
  gopassBin = "${pkgs.gopass}/bin/gopass";
  grimBin = "${pkgs.grim}/bin/grim";
  i3dmenuBin = "${pkgs.i3}/bin/i3-dmenu-desktop";
  lightBin = "${pkgs.light}/bin/light";
  makoctlBin = "${pkgs.mako}/bin/makoctl";
  mkdirBin = "${pkgs.coreutils}/bin/mkdir";
  notifySendBin = "${pkgs.libnotify}/bin/notify-send";
  pactlBin = "${pkgs.pulseaudio}/bin/pactl";
  pkillBin = "${pkgs.procps}/bin/pkill";
  playerctlBin = "${pkgs.playerctl}/bin/playerctl";
  slurpBin = "${pkgs.slurp}/bin/slurp";
  sshaddBin = "${pkgs.openssh}/bin/ssh-add";
  swayidleBin = "${pkgs.swayidle}/bin/swayidle";
  swaylockBin = "${pkgs.swaylock}/bin/swaylock";
  swaylockCmd = "${swaylockBin} -i ${defaultWallpaper} --scaling=fill";
  swaymsgBin = "${pkgs.sway}/bin/swaymsg";
  systemctlBin = "${pkgs.systemd}/bin/systemctl";
in {
  options.local.swaywm.enable = mkEnableOption "setup sway, bar, etc";

  config = mkIf config.local.swaywm.enable {
    home.packages = with pkgs; [
      fzf
      gopass
      grim
      i3
      libappindicator-gtk3
      libnotify
      mako
      networkmanagerapplet
      playerctl
      slurp
      waybar
      wf-recorder
      wl-clipboard
    ];

    local.alacritty.enable = true;

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
      set $base00 #282c34
      set $base01 #353b45
      set $base02 #3e4451
      set $base03 #545862
      set $base04 #565c64
      set $base05 #abb2bf
      set $base06 #b6bdca
      set $base07 #c8ccd4
      set $base08 #e06c75
      set $base09 #d19a66
      set $base0A #e5c07b
      set $base0B #98c379
      set $base0C #56b6c2
      set $base0D #61afef
      set $base0E #c678dd
      set $base0F #be5046

      # Wallpaper (default)
      set $wallpaper ${defaultWallpaper}

      # Include other config parts
      include ${swayDir}/config.d/*
    '';

    home.file."${swayDir}/config.d/10-systemd".text = ''
      exec "${systemctlBin} --user import-environment HOME I3SOCK PATH SSH_AUTH_SOCK SWAYSOCK USER WAYLAND_DISPLAY; ${systemctlBin} --user start sway-session.target"
    '';

    home.file."${swayDir}/config.d/10-outputs".text = ''
      # You can get the names of your outputs by running: swaymsg -t get_outputs
      ${(if nixosConfig.local.hardware.machine == "kvm" then ''
        output Virtual-1    resolution 1920x1080 position 0,0
      '' else
        "")}
      ${(if nixosConfig.local.hardware.machine == "alienware-15r2" then ''
        output eDP-1    resolution 1920x1080 position 0,0
      '' else
        "")}
      ${(if nixosConfig.networking.hostName == "knopa" then ''
        output DP-1    resolution 1920x1080 position 0,0
        output HDMI-A-1 resolution 1920x1080 position 1920,0
      '' else
        "")}
      ${(if nixosConfig.local.hardware.machine == "thinkpad-T430s" then ''
        output eDP-1   resolution 1600x900 position 0,0
      '' else
        "")}

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
      font pango:Noto Sans 12

      # class                 border  backgr. text    indicat child
      client.focused          $base05 $base0D $base00 $base0D $base0D
      client.focused_inactive $base01 $base01 $base05 $base03 $base01
      client.unfocused        $base01 $base00 $base05 $base01 $base01
      client.urgent           $base08 $base08 $base00 $base08 $base08
      client.placeholder      $base00 $base00 $base05 $base00 $base00
      client.background       $base07

      default_border pixel 1
      default_floating_border pixel 1

      gaps outer 0
      gaps inner 6
      smart_gaps on
      smart_borders no_gaps
      hide_edge_borders smart

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

      # bind program to scratchpad
      for_window [title="Telegram"] move scratchpad
      exec --no-startup-id ${pkgs.tdesktop}/bin/telegram-desktop
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
      set $ws10 10

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
      '' else
        "")}

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
    '';

    home.file."${swayDir}/config.d/50-autolayout".text = ''
      # set floating (nontiling) for special apps
      # for_window [class="Gnome-control-center" instance="gnome-control-center"] floating enable

      # auto fullscreen
      for_window [title="Media viewer"] fullscreen enable
    '';

    home.file."${swayDir}/config.d/60-terminal".text = ''
      # Your preferred terminal emulator
      set $term ${alacrittyBin}

      # start a terminal
      bindsym $mod+Return      exec $term
      bindsym $mod+Ctrl+Return exec $term
    '';

    home.file."${swayDir}/config.d/70-launcher".text = ''
      # Your preferred application launcher
      set $menu ${alacrittyBin} --class=launcher -e ${i3dmenuBin} --dmenu="${fzfBin} --prompt='Run: ' --cycle --print-query | tail -n1"
      for_window [app_id="^launcher$"] floating enable, resize set width 649 px height 300 px

      # start your launcher
      bindsym $mod+d           exec $menu
      bindsym $mod+Cyrillic_ve exec $menu
    '';

    home.file."${swayDir}/config.d/70-mako".text = ''
      bindsym $mod+n exec ${makoctlBin} dismiss
      bindsym $mod+Shift+n exec ${makoctlBin} dismiss --all
    '';

    home.file."${swayDir}/config.d/70-backlight".text = ''
      bindsym --locked XF86MonBrightnessUp   exec ${lightBin} -A 3
      bindsym --locked XF86MonBrightnessDown exec ${lightBin} -U 3
    '';

    home.file."${swayDir}/config.d/70-volume".text = ''
      bindsym --locked XF86AudioMute exec --no-startup-id sh -c \
        "for s in \$(${pactlBin} list sinks short | cut -f1); do ${pactlBin} set-sink-mute \$s toggle; done"
      bindsym --locked XF86AudioLowerVolume exec --no-startup-id \
        ${pactlBin} set-sink-volume $(${pactlBin} list sinks short | head -n 1 | cut -f1) -0.99%
      bindsym --locked XF86AudioRaiseVolume exec --no-startup-id \
        ${pactlBin} set-sink-volume $(${pactlBin} list sinks short | head -n 1 | cut -f1) +0.99%
      bindsym --locked XF86AudioMicMute exec --no-startup-id sh -c \
        "for s in \$(${pactlBin} list sources short | cut -f1); do ${pactlBin} set-source-mute \$s toggle; done"
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

    home.file."${swayDir}/config.d/70-passmenu".text = ''
      set $passmenu ${alacrittyBin} --class=passmenu -e ${bashBin} -c "${gopassBin} find . | ${fzfBin} --print-query | tail -n1 | xargs -r ${swaymsgBin} -t command exec -- ${gopassBin} show -c"
      set $passmenuOTP ${alacrittyBin} --class=passmenu -e ${bashBin} -c "${gopassBin} find . | ${fzfBin} --print-query | tail -n1 | xargs -r ${swaymsgBin} -t command exec -- ${gopassBin} otp -c"

      for_window [app_id="^passmenu$"] floating enable, resize set width 649 px height 300 px

      bindsym $mod+p                 exec $passmenu
      bindsym $mod+Cyrillic_ze       exec $passmenu
      bindsym $mod+Shift+p           exec $passmenuOTP
      bindsym $mod+Shift+Cyrillic_ze exec $passmenuOTP
    '';

    home.file."${swayDir}/config.d/99-exit-menu".text = ''
      set $mode_system System: (l) lock, (c) reload config, (e) exit, (s) suspend, (r) reboot, (S) shutdown, (R) UEFI
      mode "$mode_system" {
          bindsym l exec --no-startup-id ${swaylockCmd}, mode "default"
          bindsym c reload
          bindsym e exit
          bindsym s exec --no-startup-id ${systemctlBin} suspend -i, mode "default"
          bindsym r exec --no-startup-id ${systemctlBin} reboot -i, mode "default"
          bindsym Shift+s exec --no-startup-id ${systemctlBin} poweroff -i, mode "default"
          bindsym Shift+r exec --no-startup-id ${systemctlBin} reboot -i --firmware-setup, mode "default"

          # return to default mode
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+Shift+e          mode "$mode_system"
      bindsym $mod+Shift+Cyrillic_u mode "$mode_system"
    '';

    home.file."${swayDir}/config.d/99-unlock-ssh".text = ''
      exec --no-startup-id sh -c "echo | ${sshaddBin}"
    '';

    #
    # waybar
    #
    home.file."${config.xdg.configHome}/waybar/ipcountry.sh".text = ''
      #!/usr/bin/env bash
      CODE=$(curl -s http://ifconfig.co/country-iso)
      echo "{ \"class\": \"$CODE\", \"text\": \"$CODE\" }"
    '';

    home.file."${config.xdg.configHome}/waybar/config".text = builtins.toJSON ({
      modules-left = [ "sway/workspaces" "sway/mode" ];
      "sway/workspaces" = {
        disable-scroll = true;
        format = "{name}: {icon}";
        format-icons = {
          # "1" = "";
          # "2" = "";
          # "3" = "";
          # "4" = "";
          # "5" = "";
          "urgent" = "";
          "focused" = "";
          "default" = "";
        };
      };
      "sway/mode" = { format = ''<span style="italic">{}</span>''; };

      modules-center = [ "sway/window" ];
      "sway/window" = { max-length = 100; };

      modules-right = [
        "tray"
        "idle_inhibitor"
        "cpu"
        "temperature"
        "memory"
        "custom/ipcountry"
        "network"
        "pulseaudio"
        "clock"
      ];
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      cpu = {
        states = { critical = 75; };
        format = "{usage}% ";
        tooltip = false;
      };
      memory = {
        format = "{}% ";
        states = { critical = 90; };
      };

      temperature = {
        format = "{temperatureC}°C ";
        critical-threshold = 80;
      } // (if (nixosConfig.local.hardware.machine == "alienware-15r2") then {
        thermal-zone = 1;
      } else
        { });

      battery = {
        states = {
          "awesome" = 90;
          "good" = 80;
          "warning" = 30;
          "critical" = 15;
        };
        format = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        format-awesome = "";
      };
      "custom/ipcountry" = {
        exec = "bash ${config.xdg.configHome}/waybar/ipcountry.sh";
        return-type = "json";
        interval = 60;
        tooltip = false;
      };
      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        tooltip-format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        format-alt = " {bandwidthUpBits}↑ {bandwidthDownBits}↓";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      };
      pulseaudio = {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          headphones = "";
          handsfree = "";
          headset = "";
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
        scroll-step = 1.0e-2;
      };
      backlight = {
        format = "{percent}% {icon}";
        format-icons = [ "" "" ];
      };
      clock = {
        format-alt = " {:%a, %d. %b  %H:%M}";
        tooltip = false;
      };
    } // (if (nixosConfig.local.hardware.machine == "alienware-15r2") then {
      modules-right = [
        "tray"
        "idle_inhibitor"
        "cpu"
        "temperature"
        "memory"
        "battery"
        "custom/ipcountry"
        "network"
        "pulseaudio"
        "backlight"
        "clock"
      ];
    } else if (nixosConfig.local.hardware.machine == "thinkpad-T430s") then {
      modules-right = [
        "tray"
        "idle_inhibitor"
        "cpu"
        "temperature"
        "memory"
        "battery"
        "custom/ipcountry"
        "network"
        "pulseaudio"
        "backlight"
        "clock"
      ];
    } else
      { }));

    home.file."${config.xdg.configHome}/waybar/style.css".text =
      builtins.readFile ./waybar.css;

    #
    # mako
    #
    home.file."${config.xdg.configHome}/mako/config".text = ''
      font=pango:Noto Sans 10
      markup=1

      ## Base16 OneDark
      # Author: Lalit Magant (http://github.com/tilal6991)
      #
      # You can use these variables anywhere in the mako configuration file.

      background-color=#3e4451
      text-color=#abb2bf
      border-color=#abb2bf

      [urgency=low]
      background-color=#353b45
      text-color=#545862
      border-color=#abb2bf

      [urgency=high]
      background-color=#e06c75
      text-color=#b6bdca
      border-color=#abb2bf
    '';

    services.gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" "ssh" ];
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
          ExecStart = "${pkgs.mako}/bin/mako";
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
      swayidle = {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = "graphical-session.target";
        };
        Service = {
          Type = "simple";
          Environment = "PATH=${pkgs.bash}/bin";
          ExecStart = ''
            ${swayidleBin} -w \
              timeout 600  '${swaylockCmd} -f' \
              timeout 1200 '${swaymsgBin} "output * dpms off"' \
                    resume '${swaymsgBin} "output * dpms on"' \
              before-sleep '${swaylockCmd} -f'
          '';
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
      waybar = {
        Unit = {
          Description =
            "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
          Documentation = "man:waybar(1)";
          PartOf = "graphical-session.target";
        };
        Service = {
          Type = "dbus";
          BusName = "fr.arouillard.waybar";
          ExecStart = "${pkgs.waybar}/bin/waybar";
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
    };
  };
}
