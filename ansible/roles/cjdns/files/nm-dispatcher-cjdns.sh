#!/bin/sh

interface=$1
status=$2

beginswith() { case $2 in "$1"*) true;; *) false;; esac; }
restart_cjdns() { systemctl restart cjdns; }

if [ "$status" = "up" ]; then
  if beginswith wlp "$interface"; then restart_cjdns; fi
  if beginswith enp "$interface"; then restart_cjdns; fi
  if beginswith eth "$interface"; then restart_cjdns; fi
  if beginswith wlan "$interface"; then restart_cjdns; fi
fi
