{ config, lib, pkgs, ... }:
with lib; {
  options.knopki.tmux.enable = mkEnableOption "setup tmux";

  config = mkIf config.knopki.tmux.enable {
    programs.tmux = {
      # windows start from 1
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

        # jump to left/right window
        bind-key -n M-PPage previous-window
        bind-key -n M-NPage next-window

        # mouse
        set -g mouse on

        # mouse scrolling
        bind -n WheelUpPane   if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
        bind -n WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"

        # fix keys
        set-window-option -g xterm-keys on

        # statusbar
        set -g status on
        set -g status-position bottom
        set -g status-justify left
        set -g status-left-length 5 # 20
        set -g status-right-length 90 # 50

        set-option -g status-bg colour235 #base02
        set-option -g status-fg colour136 #yellow
        set-option -g status-attr default
        set-window-option -g window-status-style "fg=colour244,bg=default"
        set-window-option -g window-status-current-style "fg=colour166,bg=default"

        set-option -g pane-border-fg colour235 #base02
        set-option -g pane-active-border-fg colour240 #base01

        set-option -g message-bg colour235 #base02
        set-option -g message-fg colour166 #orange

        set-option -g display-panes-active-colour colour33 #blue
        set-option -g display-panes-colour colour166 #orange

        set-window-option -g clock-mode-colour colour64 #green

        set-window-option -g window-status-format "#I:#W "
        set-window-option -g window-status-current-format "#I:#W "

        set -g status-left '#[fg=colour235,bg=colour148] #S #[fg=colour148,bg=colour235] '
        set -g status-right ' #[fg=colour33,bg=colour235]#[fg=colour0,bg=colour33] #(hostname -s)  '
      '';
      newSession = true;
      plugins = with pkgs; [ tmuxPlugins.pain-control ];
      terminal = "screen-256color";
    };
  };
}
