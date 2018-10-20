# Prints the uptime.


if shell_is_bsd; then
    TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT="/usr/local/bin/grep"
else
    TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT="grep"
fi

__process_settings() {
    if [ -z "$TMUX_POWERLINE_SEG_UPTIME_GREP" ]; then
        export TMUX_POWERLINE_SEG_UPTIME_GREP="${TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT}"
    fi
}

run_segment() {
    __process_settings
    # Assume latest grep is in PATH
    gnugrep="${TMUX_POWERLINE_SEG_UPTIME_GREP}"
    echo $(uptime | $gnugrep -PZo "(?<=up )[^,]*") $'\uF201 '
    return 0
}
