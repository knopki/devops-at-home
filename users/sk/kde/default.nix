{ config, lib, pkgs, nixosConfig, ... }:
let
  inherit (builtins) toString listToAttrs map;
  inherit (lib) mkMerge mkIf;
in
{
  programs.kde = {
    settings = {
      kdeglobals.General.BrowserApplication = "brave-browser.desktop";

      kactivitymanagerdrc = {
        Plugins = {
          "org.kde.ActivityManager.VirtualDesktopSwitchEnabled" = true;
        };
        activities = {
          "0da38162-91a8-4f68-9bff-8c318a46edc6" = "Default";
          "ee03f0f7-8175-48f9-b239-ed505c53b864" = "Gaming";
          "fdd73bec-54ba-445a-9be8-f427d6aa56d6" = "Working";
        };
        activities-icons = {
          "ee03f0f7-8175-48f9-b239-ed505c53b864" = "preferences-desktop-gaming";
          "fdd73bec-54ba-445a-9be8-f427d6aa56d6" = "planwork";
        };
      };

      kscreenlockerrc = {
        Daemon.Timeout = 15;
      };

      kwalletrc.Wallet = {
        Enabled = true;
        "Default Wallet" = "kdewallet";
        "Leave Open" = true;
        "Use One Wallet" = true;
      };

      kwinrc = {
        Plugins.bismuthEnabled = true;
        Plugins.lattewindowcolorsEnabled = true;
        Script-bismuth = {
          # reference: https://github.com/Bismuth-Forge/bismuth/blob/master/src/config/bismuth_config.kcfg
          maximizeSoleTile = true;
          tileLayoutGap = 5;
          # experimentalBackend = true;
          floatingTitle = [ "imv" "SpeedCrunch" ];
          ignoreTitle = [ "MetaMask Notification" ];
          ignoreRole = "pop-up";
        };
        Desktops = {
          Id_1 = "b8f777df-3a74-4bb1-9323-76c522965b2e";
          Id_2 = "5bc900c5-26d9-4b9e-98b9-5f0a8ee88e51";
          Id_3 = "c3a14783-7b31-495c-b3bd-47e73caa784f";
          Id_4 = "f15059f7-d2da-44ed-b6e6-1cd163259ea4";
          Id_5 = "c942e3a2-0087-40e8-a098-3ce79f275254";
          Id_6 = "9c47220e-3d2e-4ce9-a5b0-7b80fde1b1ae";
          Id_7 = "af20d7e1-b7ed-4cc3-a6d9-169c80826a13";
          Id_8 = "00b372f8-68df-496c-82cd-2a5e9191d50c";
          Id_9 = "93c94ddf-78d9-4786-9ee2-70c00704900e";
          Id_10 = "9cbdcf6b-2721-418c-82aa-1c11b346a382";
          Name_1 = 1;
          Name_2 = 2;
          Name_3 = 3;
          Name_4 = 4;
          Name_5 = 5;
          Name_6 = 6;
          Name_7 = 7;
          Name_8 = 8;
          Name_9 = 9;
          Name_10 = 10;
          Number = 10;
          Rows = 1;
        };
        NightColor = {
          Active = true;
        };
      };

      # hotkeys
      kglobalshortcutsrc = {
        "Alacritty.desktop" = {
          _k_friendly_name = "Alacritty";
          _launch = [ "Meta+Return" "" "Alacritty" ];
        };
        "krunner.desktop" = {
          _k_friendly_name = "KRunner";
          _launch = [ "Alt+F2\tSearch" "Alt+F2\tSearch" "KRunner" ];
        };
        kwin = {
          "Switch to Desktop 1" = [ "Meta+1" "none" "" ];
          "Switch to Desktop 2" = [ "Meta+2" "none" "" ];
          "Switch to Desktop 3" = [ "Meta+3" "none" "" ];
          "Switch to Desktop 4" = [ "Meta+4" "none" "" ];
          "Switch to Desktop 5" = [ "Meta+5" "none" "" ];
          "Switch to Desktop 6" = [ "Meta+6" "none" "" ];
          "Switch to Desktop 7" = [ "Meta+7" "none" "" ];
          "Switch to Desktop 8" = [ "Meta+8" "none" "" ];
          "Switch to Desktop 9" = [ "Meta+9" "none" "" ];
          "Switch to Desktop 10" = [ "Meta+0" "none" "" ];

          "Window to Desktop 1" = [ "Meta+!" "none" "" ];
          "Window to Desktop 2" = [ "Meta+@" "none" "" ];
          "Window to Desktop 3" = [ "Meta+#" "none" "" ];
          "Window to Desktop 4" = [ "Meta+$" "none" "" ];
          "Window to Desktop 5" = [ "Meta+%" "none" "" ];
          "Window to Desktop 6" = [ "Meta+^" "none" "" ];
          "Window to Desktop 7" = [ "Meta+&" "none" "" ];
          "Window to Desktop 8" = [ "Meta+*" "none" "" ];
          "Window to Desktop 9" = [ "Meta+(" "none" "" ];
          "Window to Desktop 10" = [ "Meta+)" "none" "" ];

          "Switch to Next Screen" = [ "Meta+." "none" "" ];
          "Switch to Previous Screen" = [ "Meta+," "none" "" ];

          "Window to Next Screen" = [ "Meta+>" "Meta+Shift+Right" "" ];
          "Window to Previous Screen" = [ "Meta+<" "Meta+Shift+Left" "" ];

          "Window Close" = [ "Meta+Shift+Q\tAlt+F4" "Alt+F4" "" ];
        };

        "org.kde.dolphin.desktop" = {
          _k_friendly_name = "Dolphin";
          _launch = [ "Meta+E" "Meta+E" "" ];
        };

        "speedcrunch.desktop" = {
          _k_friendly_name = "SpeedCrunch";
          _launch = [ "Meta+C" "" "SpeedCrunch" ];
        };

        bismuth = {
          _k_friendly_name = "Window Tiling";
          decrease_master_size = [ "Meta+Ctrl+J" "Meta+Ctrl+J" "Decrease Master Area Size" ];
          decrease_master_win_count = [ "Meta+[" "Meta+[" "Decrease Master Area Window Count" ];
          decrease_window_height = [ "Meta+Ctrl+K" "Meta+Ctrl+K" "Decrease Window Height" ];
          decrease_window_width = [ "Meta+Ctrl+H" "Meta+Ctrl+H" "Decrease Window Width" ];
          focus_bottom_window = [ "Meta+J" "Meta+J" "Focus Bottom Window" ];
          focus_left_window = [ "Meta+H" "Meta+H" "Focus Left Window" ];
          focus_next_window = [ "none" "none" "Focus Next Window" ];
          focus_prev_window = [ "none" "none" "Focus Previous Window" ];
          focus_right_window = [ "Meta+L" "Meta+L" "Focus Right Window" ];
          focus_upper_window = [ "Meta+K" "Meta+K" "Focus Upper Window" ];
          increase_master_size = [ "Meta+Ctrl+K" "Meta+Ctrl+K" "Increase Master Area Size" ];
          increase_master_win_count = [ "Meta+]" "Meta+]" "Increase Master Area Window Count" ];
          increase_window_height = [ "Meta+Ctrl+J" "Meta+Ctrl+J" "Increase Window Height" ];
          increase_window_width = [ "Meta+Ctrl+L" "Meta+Ctrl+L" "Increase Window Width" ];
          move_window_to_bottom_pos = [ "Meta+Shift+J" "Meta+Shift+J" "Move Window Down" ];
          move_window_to_left_pos = [ "Meta+Shift+H" "Meta+Shift+H" "Move Window Left" ];
          move_window_to_next_pos = [ "none" "none" "Move Window to the Next Position" ];
          move_window_to_prev_pos = [ "none" "none" "Move Window to the Previous Position" ];
          move_window_to_right_pos = [ "Meta+Shift+L" "Meta+Shift+L" "Move Window Right" ];
          move_window_to_upper_pos = [ "Meta+Shift+K" "Meta+Shift+K" "Move Window Up" ];
          next_layout = [ "Meta+\\" "Meta+\\" "Switch to the Next Layout" ];
          prev_layout = [ "Meta+|" "Meta+|" "Switch to the Previous Layout" ];
          push_window_to_master = [ "Meta+M" "Meta+M" "Push Active Window to Master Area" ];
          rotate = [ "Meta+R" "Meta+R" "Rotate" ];
          rotate_part = [ "Meta+Shift+R" "Meta+Shift+R" "Rotate Part" ];
          rotate_reverse = [ "none" "none" "Rotate (Reverse)" ];
          toggle_float_layout = [ "Meta+Shift+F" "Meta+Shift+F" "Toggle Floating Layout" ];
          toggle_monocle_layout = [ "none" "none" "Toggle Monocle Layout" ];
          toggle_quarter_layout = [ "none" "none" "Toggle Quarter Layout" ];
          toggle_spiral_layout = [ "none" "none" "Toggle Spiral Layout" ];
          toggle_spread_layout = [ "none" "none" "Toggle Spread Layout" ];
          toggle_stair_layout = [ "none" "none" "Toggle Stair Layout" ];
          toggle_three_column_layout = [ "none" "none" "Toggle Three Column Layout" ];
          toggle_tile_layout = [ "Meta+T" "Meta+T" "Toggle Tile Layout" ];
          toggle_window_floating = [ "Meta+F" "Meta+F" "Toggle Active Window Floating" ];
        };

        lattedock = listToAttrs (map
          (x:
            let name = "activate entry ${toString (if x == 0 then 10 else x)}"; in
            { inherit name; value = [ "none" "Meta+${toString x}" name ]; }) [ 0 1 2 3 4 5 6 7 8 9 ]);

        plasmashell = listToAttrs (map
          (x:
            let name = "activate task manager entry ${toString (if x == 0 then 10 else x)}"; in
            { inherit name; value = [ "none" "none" name ]; }) [ 0 1 2 3 4 5 6 7 8 9 ]);
      };

      kwinrulesrc = {
        General.count = 1;
        # fix tiling for windows with big minimal size
        "1" = {
          Description = "Setting Minimum Geometry Size";
          minsize = [ 1 1 ];
          minsizerule = 2;
          types = 1;
        };
      };

      lattedockrc = {
        UniversalSettings = {
          canDisableBorders = true;
          inAdvancedModeForEditSettings = true;
          metaPressAndHoldEnabled = true;
          unifiedGlobalShortcuts = false;
          singleModeLayoutName = "Main";
          contextMenuActionsAlwaysShown = [ "_layouts" "_preferences" "_add_latte_widgets" ];
        };
      };
    };
  };

  # powermanager - just copy
  xdg.configFile."powermanagementprofilesrc" = {
    text = builtins.readFile ./powermanagementprofilesrc;
    force = true;
  };

  # latte dock layout
  xdg.configFile."latte/Main.layout.latte" = {
    text = builtins.readFile ./Main.layout.latte;
    force = true;
    onChange = ''
      ${pkgs.gnused}/bin/sed -i ';' ${config.xdg.configHome}/latte/Main.layout.latte
    '';
  };

  # autostart latte dock
  xdg.configFile."autostart/org.kde.latte-dock.desktop".source =
    "${pkgs.latte-dock}/etc/xdg/autostart/org.kde.latte-dock.desktop";

  # enable kwin scripts
  xdg.dataFile."kservices5/kwinscript-window-colors.desktop".source =
    "${pkgs.kwinscript-window-colors}/share/kservices5/kwinscript-window-colors.desktop";
  xdg.dataFile."kservices5/bismuth.desktop".source =
    "${pkgs.plasma5Packages.bismuth}/share/kservices5/bismuth.desktop";
}
