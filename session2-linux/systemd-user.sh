#!/usr/bin/env bash
# Only run on the disposable GitHub-hosted Ubuntu runner.
set -euxo pipefail
test "${GITHUB_ACTIONS:-}" = "true"
test "$(ps -p 1 -o comm=)" = systemd
test -z "$(getent passwd kitledger-lab || true)"
sudo adduser --disabled-password --gecos 'KitLedger temporary lab' kitledger-lab
id kitledger-lab
getent passwd kitledger-lab
sudo deluser --remove-home kitledger-lab
! getent passwd kitledger-lab
journalctl --version
sudo journalctl -n 20 --no-pager
sudo journalctl -u systemd-journald -n 20 --no-pager
systemctl status systemd-journald --no-pager
