run_segment() {
  local ramfree=0
  #ramfree=$(grep -o -E "MemFree:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
  ramavail=$(grep -o -E "MemAvailable:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
  echo $(echo "scale=2; $ramavail / 1024 / 1024" | bc)G $'\uF0E4 '

  return 0
}
