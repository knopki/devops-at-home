{ config, lib, pkgs, user, nixosConfig, ... }:
with lib; {
  options.local.tmux.enable = mkEnableOption "setup tmux";

  config = mkIf config.local.tmux.enable {
    home.packages = with pkgs; [ bc ];

    home.file = {
      ".tmux-powerlinerc".text = ''
        # Default configuration file for tmux-powerline.
        # Modeline {
        #	 vi: foldmarker={,} foldmethod=marker foldlevel=0 tabstop=4 filetype=sh
        # }

        # General {
          # Show which segment fails and its exit code.
          export TMUX_POWERLINE_DEBUG_MODE_ENABLED="false"
          # Use patched font symbols.
          export TMUX_POWERLINE_PATCHED_FONT_IN_USE="true"
          # The theme to use.
          export TMUX_POWERLINE_THEME="mytheme"
          # Overlay directory to look for themes. There you can put your own themes outside the repo. Fallback will still be the "themes" directory in the repo.
          export TMUX_POWERLINE_DIR_USER_THEMES="~/.tmux/powerline/themes"
          # Overlay directory to look for segments. There you can put your own segments outside the repo. Fallback will still be the "segments" directory in the repo.
          export TMUX_POWERLINE_DIR_USER_SEGMENTS="~/.tmux/powerline/segments"
        # }

        # date.sh {
          # date(1) format for the date. If you don't, for some reason, like ISO 8601 format you might want to have "%D" or "%m/%d/%Y".
          export TMUX_POWERLINE_SEG_DATE_FORMAT="%F"
        # }

        # hostname.sh {
          # Use short or long format for the hostname. Can be {"short, long"}.
          export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="short"
        # }

        # time.sh {
          # date(1) format for the time. Americans might want to have "%I:%M %p".
          export TMUX_POWERLINE_SEG_TIME_FORMAT="%H:%M"
        # }

        # uptime.sh {
          # Name of GNU grep binary if in PATH, or path to it.
          export TMUX_POWERLINE_SEG_UPTIME_GREP="grep"
        # }

        export TMUX_POWERLINE_SEG_CONTEXT_DEFAULT_USER="sk"
      '';

      ".tmux/powerline/themes/mytheme.sh".text = ''
        # Default Theme

        if patched_font_in_use; then
          TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
          TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
          TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
          TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
        else
          TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
          TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
          TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
          TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
        fi

        TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=''${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-'235'}
        TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=''${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'255'}

        TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=''${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
        TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=''${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}


        # Format: segment_name background_color foreground_color [non_default_separator]

        if [ -z $TMUX_POWERLINE_LEFT_STATUS_SEGMENTS ]; then
          TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
            "tmux_session_info 148 234" \
          )
        fi

        if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
          TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
            "context 33 0" \
            "cpu 2 235" \
            "mem 3 235" \
            "uptime 9 235" \
            "date_day 235 136" \
            "date 235 136 ''${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
            "time 235 136 ''${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
          )
        fi
      '';

      ".tmux/powerline/segments/context.sh".text = ''
        run_segment() {
          hostname=""
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
            hostname=$(hostname -s)
          fi

          user=""
          if [ "$USER" != "$TMUX_POWERLINE_SEG_CONTEXT_DEFAULT_USER" ]; then
            user=$USER
          fi

          result=""
          if [ ! -z $user ]; then result=$user; fi
          if [ ! -z $user ] && [ ! -z $hostname ]; then result="''${result}@"; fi
          if [ ! -z $hostname ]; then result="''${result}''${hostname}"; fi

          if [ ! -z $result ]; then echo $result $'\uF296 '; fi
          return 0
        }
      '';

      ".tmux/powerline/segments/cpu.sh".text = ''
        run_segment() {
          if [[ "$OS" == "OSX" ]] || [[ "$OS" == "BSD" ]]; then
            load_avg_1min=$(sysctl vm.loadavg | grep -o -E '[0-9]+(\.|,)[0-9]+' | head -n 1)
          else
            load_avg_1min=$(grep -o "[0-9.]*" /proc/loadavg | head -n 1)
          fi

          # Replace comma
          load_avg_1min=''${load_avg_1min//,/.}

          echo "$load_avg_1min" $'\uF080 '

          return 0
        }
      '';

      ".tmux/powerline/segments/mem.sh".text = ''
        run_segment() {
          local ramfree=0
          #ramfree=$(grep -o -E "MemFree:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
          ramavail=$(grep -o -E "MemAvailable:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
          echo $(echo "scale=2; $ramavail / 1024 / 1024" | bc)G $'\uF0E4 '

          return 0
        }
      '';

      ".tmux/powerline/segments/tmux_session_info.sh".text = ''
        # Prints tmux session info.
        # Assuems that [ -n "$TMUX"].

        run_segment() {
          tmux display-message -p '#S'
          return 0
        }
      '';

      ".tmux/powerline/segments/uptime.sh".text = ''
        # Prints the uptime.

        if shell_is_bsd; then
            TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT="/usr/local/bin/grep"
        else
            TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT="grep"
        fi

        __process_settings() {
            if [ -z "$TMUX_POWERLINE_SEG_UPTIME_GREP" ]; then
                export TMUX_POWERLINE_SEG_UPTIME_GREP="''${TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT}"
            fi
        }

        run_segment() {
            __process_settings
            # Assume latest grep is in PATH
            gnugrep="''${TMUX_POWERLINE_SEG_UPTIME_GREP}"
            echo $(uptime | $gnugrep -PZo "(?<=up )[^,]*") $'\uF201 '
            return 0
        }
      '';
    };

    programs.tmux = {
      baseIndex = 1;
      clock24 = true;
      enable = true;
      extraConfig = ''
        # enable activity alerts
        setw -g monitor-activity on
        set -g visual-activity off
        set-option -g bell-action none

        # change terminal info
        set -g set-titles on
        set -g set-titles-string "#T"

        # windows start from 1
        set -g base-index 1

        # jump to left/right window
        bind-key -n M-PPage previous-window
        bind-key -n M-NPage next-window

        # mouse
        set -g mouse on

        # mouse scrolling
        bind -n WheelUpPane   if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
        bind -n WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"
        #bind -t emacs-copy WheelUpPane   page-up
        #bind -t emacs-copy WheelDownPane page-down

        # fix keys
        set-window-option -g xterm-keys on

        # htop/top
        bind-key t new-window "htop || top"
      '';
      newSession = true;
      plugins = with pkgs; [
        tmuxPlugins.pain-control
        tmuxPlugins.tmux-colors-solarized
        {
          plugin = tmuxPlugins.tmux-powerline;
          extraConfig = ''
                      set-option -g status on
                      set-option -g status-interval 3
                      set-option -g status-justify "left"
                      set-option -g status-left-length 5
                      set-option -g status-right-length 90
                      set-option -g status-left "#(${pkgs.tmuxPlugins.tmux-powerline}/share/tmux-plugins/tmux-powerline/powerline.sh left) "
            set-option -g status-right "#(${pkgs.tmuxPlugins.tmux-powerline}/share/tmux-plugins/tmux-powerline/powerline.sh right)"
                      set-window-option -g window-status-current-format "#I:#W "
                      set-window-option -g window-status-format "#I:#W "
                    '';
        }
      ];
      terminal = "screen-256color";
    };
  };
}
