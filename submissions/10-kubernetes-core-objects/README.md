# Session 10: Kubernetes Pods, ReplicaSets & Deployments

Yash Agrawal · 24bcs10164

Source: [app.yaml](app.yaml), [12 lifecycle manifests](pod-lifecycle), [verify.sh](verify.sh).
```sh
bash submissions/10-kubernetes-core-objects/verify.sh
```
Run only with the disposable coursework namespace/context selected.
The script deletes a Pod and observes replacement, scales replicas, performs
rolling update/undo, switches a Service between blue/green, samples canary
responses, watches Recreate, and applies/describes all lifecycle cases.

Pending means scheduling/startup remains incomplete; Running does not imply
Ready; Succeeded/Failed refer to termination. CrashLoopBackOff/ImagePullBackOff
are container waiting reasons, not standalone Pod phases. Startup gates other
probes; readiness controls traffic; liveness restarts a failed container.
Init containers finish before regular containers, sidecars can run alongside the
main process, and termination involves grace periods/signals.

The corrected canary uses three stable Pods plus one canary, an approximate 25%
selection chance. It does not guarantee exactly 25% of a small request sample.
[Initial actual output](../../evidence/ci/kubernetes-38448657607/10-kubernetes-core-objects.log);
the newer ratio correction requires the corresponding rerun evidence.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
