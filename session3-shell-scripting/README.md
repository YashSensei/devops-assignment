# Session 3: Shell Scripting

Yash Agrawal · 24bcs10164

Implementation: [system-info.sh](system-info.sh).
```sh
printf 'coursework run\n' | bash session3-shell-scripting/system-info.sh
```
The script stores name/enrollment in variables, accepts read -p input, prints date,
hostname, username, df and ps, then creates a temporary directory/file and redirects
the process list into it. It runs under Bash on the disposable Linux runner.
PowerShell is not claimed to be Bash.
[Actual output](../evidence/ci/foundations-38448115326/system-info.log) and
[green foundation run](https://github.com/YashSensei/devops-assignment/actions/runs/38449941808).

See [the completion audit](../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
