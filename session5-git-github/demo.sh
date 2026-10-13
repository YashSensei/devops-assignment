#!/usr/bin/env bash
set -euxo pipefail
demo="$(mktemp -d /tmp/kitledger-git.XXXXXX)"
cd "$demo"
git init -b main
git config user.name 'Yash Agrawal'
git config user.email 'yash.24bcs10164@sst.scaler.com'
printf 'initial\n' > tracked.txt
git add tracked.txt
git commit -m 'Create tracked demonstration file'
printf 'staged change\n' >> tracked.txt
git add tracked.txt
git commit -m 'Commit explicitly staged edit'
printf 'automatic tracked change\n' >> tracked.txt
printf 'untracked file\n' > new.txt
git commit -a -m 'Commit tracked edit automatically'
test "$(git status --porcelain new.txt)" = '?? new.txt'
git add new.txt
git commit -m 'Explicitly add previously untracked file'
git switch -c feature-demo
printf 'selected feature\n' > selected.txt
git add selected.txt
git commit -m 'Add isolated feature selected for transfer'
chosen="$(git rev-parse HEAD)"
printf 'unselected feature\n' > unselected.txt
git add unselected.txt
git commit -m 'Add independent feature excluded from transfer'
git switch main
git cherry-pick "$chosen"
test -f selected.txt
test ! -f unselected.txt
git log --all --graph --oneline --decorate
git status --short
echo "Demo retained in disposable environment: $demo"
