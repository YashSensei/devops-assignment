# Session 15: Helm

Yash Agrawal · 24bcs10164

Source: [Notes chart](notes-chart), [verify.sh](verify.sh).
The script exercises create, repo/search, lint/template, install/list/status/get,
upgrade/history, a deliberately bad image upgrade, rollback/verification and uninstall.
The Notes example follows the licensed instructor mini-project with current
Nginx image tags; production values scale it from one to three replicas.

A chart is a package; values configure templates; a release is a deployed instance
with revision history. helm lint checks a chart, while helm install/upgrade
changes a cluster. Rollback creates a new release revision using an earlier
configuration; it does not undo database changes automatically.

[Actual successful sequence](../../evidence/ci/kubernetes-38448657607/15-helm.log).
Commands run in the dedicated coursework namespace and cleanup removes the Notes
release. Native terminal screenshots remain separately tracked.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
