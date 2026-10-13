#!/usr/bin/env bash
set -euxo pipefail
lab_dir="$(mktemp -d /tmp/kitledger-links.XXXXXX)"
cd "$lab_dir"
printf 'Yash Agrawal 24bcs10164\n' > original.txt
ln original.txt hard.txt
ln -s original.txt soft.txt
ls -li original.txt hard.txt soft.txt
stat original.txt hard.txt soft.txt
test "$(stat -c %i original.txt)" = "$(stat -c %i hard.txt)"
rm original.txt
test "$(cat hard.txt)" = "Yash Agrawal 24bcs10164"
test -L soft.txt
test ! -e soft.txt
ls -li
pwd
whoami
id
uname -a
df -h .
du -sh .
head -n 1 hard.txt
tail -n 1 hard.txt
wc -l hard.txt
grep -n Yash hard.txt
find . -maxdepth 1 -type f
chmod 640 hard.txt
ls -l hard.txt
rm soft.txt hard.txt
cd /
rmdir "$lab_dir"
