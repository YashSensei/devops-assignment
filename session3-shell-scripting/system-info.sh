#!/usr/bin/env bash
set -euo pipefail
student_name="Yash Agrawal"
enrollment="24bcs10164"
read -rp "Label this run: " run_label
run_label="${run_label:-coursework}"
output_dir="$(mktemp -d /tmp/kitledger-system.XXXXXX)"
echo "$student_name | $enrollment | $run_label"
echo "Date: $(date --iso-8601=seconds)"
echo "Hostname: $(hostname)"
echo "Username: $(whoami)"
df -h
ps aux
mkdir -p "$output_dir/processes"
touch "$output_dir/processes/list.txt"
ps aux > "$output_dir/processes/list.txt"
echo "Process list saved: $output_dir/processes/list.txt"
wc -l "$output_dir/processes/list.txt"
