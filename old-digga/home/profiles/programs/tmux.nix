{
  pkgs,
  lib,
  ...
}: {
  programs.tmux = {
    enable = lib.mkDefault true;
    # windows start from 1
    baseIndex = 1;
    clock24 = true;
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

      # show hostname
      set -g status-right ' #(hostname -s) '

      # fix alacritty 24 color
      set -ga terminal-overrides ",alacritty:Tc"
    '';
    newSession = true;
    plugins = with pkgs.tmuxPlugins; [pain-control sensible yank];
  };
}
