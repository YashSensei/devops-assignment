# Session 1&2: Linux Fundamentals

Yash Agrawal · 24bcs10164

Implementation: [links.sh](links.sh), [systemd-user.sh](systemd-user.sh), and [cheat-sheet.sh](cheat-sheet.sh).
Run them only in the approved disposable Ubuntu environment:
```sh
bash session2-linux/links.sh
bash session2-linux/systemd-user.sh
bash session2-linux/cheat-sheet.sh
```

A hard link is another directory entry for the same inode; deleting the original
name leaves its bytes reachable through the hard link. A soft link stores a path:
removing its target leaves a dangling link. Hard links normally cannot cross
filesystems or link directories.

On Debian/Ubuntu, adduser is the higher-level interactive policy wrapper; useradd
is a lower-level command whose home/shell defaults require care. The workflow
creates only kitledger-lab, observes its identity, then removes that test user.
journalctl reads the actual systemd journal; the workflow checks PID 1 and queries
systemd-journald on an Ubuntu VM. No container journal is fabricated.

The course basic/advanced/Linux-networking PDF cheat sheets were extracted and
read. Scripts cover practical file, permission, process, information and network
commands. Interactive htop/less/history shortcuts, password changes, visudo,
SSH/SCP and distro-specific yum administration remain student practice; their
examples are not proof they were executed.

Evidence: [successful Linux foundation run](https://github.com/YashSensei/devops-assignment/actions/runs/38449941808),
artifact foundation-execution-evidence. The expanded cheat-sheet run is tracked
in the root audit. Native terminal screenshots are still a separate deliverable.

See [the completion audit](../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
