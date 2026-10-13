#!/usr/bin/env bash
set -euxo pipefail
test "${GITHUB_ACTIONS:-}" = true
lab="$(mktemp -d /tmp/kitledger-cheats.XXXXXX)"
touch "$lab/example.txt"
printf 'Yash Agrawal\n24bcs10164\n' > "$lab/example.txt"
cp "$lab/example.txt" "$lab/copy.txt"
mv "$lab/copy.txt" "$lab/renamed.txt"
cat "$lab/renamed.txt"
more "$lab/renamed.txt"
head -n 1 "$lab/renamed.txt"
tail -n 1 "$lab/renamed.txt"
grep -n Yash "$lab/renamed.txt"
file "$lab/renamed.txt"
stat "$lab/renamed.txt"
umask
chmod 640 "$lab/renamed.txt"
chown "$(id -u):$(id -g)" "$lab/renamed.txt"
top -b -n 1 > "$lab/top.txt"
head -n 20 "$lab/top.txt"
free -h
vmstat 1 2
uptime
hostname
whoami
who
w
date --iso-8601=seconds
lsblk
mount | head -n 20
nice -n 10 sleep 60 &
child=$!
renice -n 15 -p "$child"
ps -p "$child" -o pid,ni,args
kill "$child"
wait "$child" || true
nohup sleep 1 > "$lab/nohup.txt" 2>&1 &
wait
du -sh "$lab"
df -h "$lab"
ls -ltr "$lab"
printf '%s\n' "$lab/example.txt" "$lab/renamed.txt" | xargs wc -l
alias ll='ls -alF'
alias ll
# Scope cleanup to the exact files this disposable exercise created.
rm "$lab/example.txt" "$lab/renamed.txt" "$lab/top.txt" "$lab/nohup.txt"
rmdir "$lab"
