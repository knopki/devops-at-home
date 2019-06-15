run_segment() {
  if [[ "$OS" == "OSX" ]] || [[ "$OS" == "BSD" ]]; then
    load_avg_1min=$(sysctl vm.loadavg | grep -o -E '[0-9]+(\.|,)[0-9]+' | head -n 1)
  else
    load_avg_1min=$(grep -o "[0-9.]*" /proc/loadavg | head -n 1)
  fi

  # Replace comma
  load_avg_1min=${load_avg_1min//,/.}

  echo "$load_avg_1min" $'\uF080 '

  return 0
}
