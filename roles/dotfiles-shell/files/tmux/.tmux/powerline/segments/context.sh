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
  if [ ! -z $user ] && [ ! -z $hostname ]; then result="${result}@"; fi
  if [ ! -z $hostname ]; then result="${result}${hostname}"; fi

  if [ ! -z $result ]; then echo $result $'\uF296 '; fi
  return 0
}
