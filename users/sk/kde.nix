{ config, lib, pkgs, nixosConfig, ... }:
let
  inherit (lib) mkMerge mkIf;
in
{
  programs.kde = {
    settings = {
      kdeglobals.General.BrowserApplication = "brave-browser.desktop";
      kwinrc = {
        Plugins.bismuthEnabled = true;
        Script-bismuth = {
          maximizeSoleTile = true;
          tileLayoutGap = 5;
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
          Rows = 2;
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
          _k_friendly_name = "KWin";

          "bismuth_decrease_master_size" = [ "none" "none" "" ];
          "bismuth_decrease_master_win_count" = [ "Meta+Shift+I" "none" "" ];
          "bismuth_decrease_window_height" = [ "Meta+Ctrl+K" "none" "" ];
          "bismuth_decrease_window_width" = [ "Meta+Ctrl+H" "none" "" ];
          "bismuth_focus_bottom_window" = [ "Meta+J" "none" "" ];
          "bismuth_focus_left_window" = [ "Meta+H" "none" "" ];
          "bismuth_focus_next_window" = [ "none" "none" "" ];
          "bismuth_focus_prev_window" = [ "none" "none" "" ];
          "bismuth_focus_right_window" = [ "Meta+L" "none" "" ];
          "bismuth_focus_upper_window" = [ "Meta+K" "none" "" ];
          "bismuth_increase_master_size" = [ "none" "none" "" ];
          "bismuth_increase_master_win_count" = [ "Meta+I" "none" "" ];
          "bismuth_increase_window_height" = [ "Meta+Ctrl+J" "none" "" ];
          "bismuth_increase_window_width" = [ "Meta+Ctrl+L" "none" "" ];
          "bismuth_move_window_to_bottom_pos" = [ "Meta+Shift+J" "none" "" ];
          "bismuth_move_window_to_left_pos" = [ "Meta+Shift+H" "none" "" ];
          "bismuth_move_window_to_next_pos" = [ "none" "none" "" ];
          "bismuth_move_window_to_prev_pos" = [ "none" "none" "" ];
          "bismuth_move_window_to_right_pos" = [ "Meta+Shift+L" "none" "" ];
          "bismuth_move_window_to_upper_pos" = [ "Meta+Shift+K" "none" "" ];
          "bismuth_next_layout" = [ "Meta+\\" "none" "" ];
          "bismuth_prev_layout" = [ "Meta+|" "none" "" ];
          "bismuth_push_window_to_master" = [ "Meta+M" "none" "" ];
          "bismuth_rotate" = [ "Meta+R" "none" "" ];
          "bismuth_rotate_part" = [ "Meta+Shift+R" "none" "" ];
          "bismuth_toggle_monocle_layout" = [ "none" "none" "" ];
          "bismuth_toggle_quarter_layout" = [ "none" "none" "" ];
          "bismuth_toggle_spread_layout" = [ "none" "none" "" ];
          "bismuth_toggle_stair_layout" = [ "none" "none" "" ];
          "bismuth_toggle_three_column_layout" = [ "none" "none" "" ];
          "bismuth_toggle_tile_layout" = [ "Meta-T" "none" "" ];
          "bismuth_toggle_window_floating" = [ "Meta+F" "none" "" ];
          "bismuth_toggle_float_layout" = [ "Meta+Shift+F" "none" "" ];

          "Switch to Desktop 1" = [ "Meta+F1" "none" "" ];
          "Switch to Desktop 2" = [ "Meta+F2" "none" "" ];
          "Switch to Desktop 3" = [ "Meta+F3" "none" "" ];
          "Switch to Desktop 4" = [ "Meta+F4" "none" "" ];
          "Switch to Desktop 5" = [ "Meta+F5" "none" "" ];
          "Switch to Desktop 6" = [ "Meta+1" "none" "" ];
          "Switch to Desktop 7" = [ "Meta+2" "none" "" ];
          "Switch to Desktop 8" = [ "Meta+3" "none" "" ];
          "Switch to Desktop 9" = [ "Meta+4" "none" "" ];
          "Switch to Desktop 10" = [ "Meta+5" "none" "" ];

          "Window to Desktop 1" = [ "Meta+Shift+F1" "none" "" ];
          "Window to Desktop 2" = [ "Meta+Shift+F2" "none" "" ];
          "Window to Desktop 3" = [ "Meta+Shift+F3" "none" "" ];
          "Window to Desktop 4" = [ "Meta+Shift+F4" "none" "" ];
          "Window to Desktop 5" = [ "Meta+Shift+F5" "none" "" ];
          "Window to Desktop 6" = [ "Meta+!" "" "" ];
          "Window to Desktop 7" = [ "Meta+@" "" "" ];
          "Window to Desktop 8" = [ "Meta+#" "" "" ];
          "Window to Desktop 9" = [ "Meta+$" "" "" ];
          "Window to Desktop 10" = [ "Meta+%" "" "" ];

          "Switch to Next Screen" = [ "Meta+." "none" "" ];
          "Switch to Previous Screen" = [ "Meta+," "none" "" ];

          "Window to Next Screen" = [ "Meta+>" "Meta+Shift+Right" "" ];
          "Window to Previous Screen" = [ "Meta+<" "Meta+Shift+Left" "" ];

          "Window Close" = [ "Meta+Shift+Q\tAlt+F4" "Alt+F4" "" ];

          "view_actual_size" = [ "Meta+0" "Meta+0" "" ];
          "view_zoom_in" = [ "Meta+=" "Meta+=" "" ];
          "view_zoom_out" = [ "Meta+-" "Meta+-" "" ];
        };

        "org.kde.dolphin.desktop" = {
          _k_friendly_name = "Dolphin";
          _launch = [ "Meta+E" "Meta+E" "" ];
        };

        "speedcrunch.desktop" = {
          _k_friendly_name = "SpeedCrunch";
          _launch = [ "Meta+C" "" "SpeedCrunch" ];
        };
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
    };
  };
}
