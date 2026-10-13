# Session 5: Git and GitHub

Yash Agrawal · 24bcs10164

Implementation: [demo.sh](demo.sh).
```sh
bash session5-git-github/demo.sh
```
git commit -m commits the index. git commit -a -m stages modifications/deletions
of already tracked files, but does not add an untracked file. This isolated demo
asserts new.txt stays untracked after -a, then explicitly adds it.

Four main commits and two feature commits demonstrate cherry-picking one selected
commit. Assertions verify selected.txt is present and unselected.txt is absent
on main. The temporary demo's history is separate from real project development.
[Commands and graph](../evidence/ci/foundations-38448115326/git.log).
The project itself has meaningful implementation/fix commits; no backdating or
trivial commit padding was used.

See [the completion audit](../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
