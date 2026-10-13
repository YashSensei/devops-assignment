# Session 13: Kubernetes Storage, HPA & Probes

Yash Agrawal · 24bcs10164

Source: [app.yaml](app.yaml), [verify.sh](verify.sh),
[storage notes](01-kubernetes-volumes/README.md).
The assigned mini-project has a 500Mi PVC at /data, two starting replicas,
startup/readiness/liveness probes and an HPA with minimum 2, maximum 5 and a 50%
CPU target. CPU requests are explicitly set (20m for this small teaching app).

The first [actual run](../../evidence/ci/kubernetes-38448657607/13-storage-hpa-probes.log)
wrote the identity, replaced a Pod, read the persisted file, generated concurrent
HTTP load, observed real scale-up, and exercised probe failure/recovery.
A configured HPA alone is not evidence of scaling. Readiness failure removes ready
endpoints; liveness failure produces restarts. Scale-down timing depends on the
stabilization window; a complete recorded return to two replicas is still tracked
separately rather than inferred.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
