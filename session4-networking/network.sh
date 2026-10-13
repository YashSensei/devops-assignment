#!/usr/bin/env bash
set -u
run() { printf '\nCOMMAND:'; printf ' %q' "$@"; printf '\n'; "$@"; code=$?; echo "EXIT=$code"; }
run ip -brief address
run ip route
run cat /etc/resolv.conf
run getent ahosts github.com
run ss -lnt
run ping -c 3 -W 2 1.1.1.1
run curl -I --connect-timeout 10 --max-time 20 https://github.com
run traceroute -m 5 -w 1 github.com
# Individual failures are observations, not a fabricated all-pass test.
