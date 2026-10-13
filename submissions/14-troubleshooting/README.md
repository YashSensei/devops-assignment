# Session 14: Kubernetes Troubleshooting

Yash Agrawal · 24bcs10164

Implementation: [verify.sh](verify.sh). It captures get/describe/logs/exec/events/
explain/top/wide output before repairs, and tests the repaired result.
Scenarios cover wrong image tags, repeated process failure, a Service label mismatch,
bad DNS configuration, an impossible node selector, missing mounted configuration
and insufficient memory. The newer scenarios require their own rerun evidence.

Image errors come from registry/tag/auth/network problems; Pending can reflect
scheduling/resources/storage; ContainerCreating often exposes volume/CNI setup
errors. OOMKilled means the kernel killed a process under memory pressure/limits;
raising a limit should follow investigation, not conceal a leak.

The first DNS repair used an ambiguous shortened query. The retry uses
kubernetes.default.svc.cluster.local after recreating the client with ClusterFirst
DNS. [Failed first run, preserved](../../evidence/ci/kubernetes-38448657607/14-troubleshooting.log).
The root audit identifies what actually passed after repair.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
