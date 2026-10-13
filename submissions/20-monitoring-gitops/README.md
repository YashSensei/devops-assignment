# Session 20: Monitoring, Observability & GitOps

Yash Agrawal · 24bcs10164

Implementation: [GitOps application](application.yaml), [watched workloads](app),
[monitoring values/dashboard](../../session21-python/monitoring),
[execution workflow](../../.github/workflows/observability.yml).

Metrics are numeric time series, logs record events, and traces connect work
across a request. Monitoring answers known health questions; observability helps
explain unexpected behavior using these signals. Prometheus scrapes metrics;
Grafana queries and visualizes them. The dashboard uses actual
kitledger_http_requests_total and latency histograms scoped to the kitledger namespace.

GitOps treats the repository as desired state. Argo CD compares it with actual
cluster state and reconciles differences. The teaching Application watches this
repository's app directory; its bootstrap manifest is outside that watched path.
The exercise begins at two replicas, observes a committed change to three and
then restores three after deliberate live drift to one.

To repeat the coordinated exercise, first commit the watched workload's baseline
back to two replicas. Dispatch observability.yml with a full green image SHA and
verify_gitops=true. When the run reaches its committed-change waiting step,
commit/push three replicas. Do not substitute a live kubectl scale for that Git
change. The runner deliberately introduces live drift afterward and verifies
reconciliation. The repository retains the final desired three-replica state.
Use verify_gitops=false to capture monitoring alone without coordinating a Git change.

For the capstone chart, HPA owns backend replica count: its template omits replicas
when autoscaling is enabled, and Argo is configured to respect that field.
Argo and an independent Helm deployment job must not simultaneously own the same
long-lived release. The standalone teaching workload is deliberately separate.

[Real GitOps run](https://github.com/YashSensei/devops-assignment/actions/runs/38453774602)
passed the committed change and drift/self-healing sequence. [Before](../../evidence/ci/gitops-38453774602/evidence/observability/drift-before.txt)
and [healed](../../evidence/ci/gitops-38453774602/evidence/observability/drift-healed.txt)
show one replica returning to three.
[Monitoring run](https://github.com/YashSensei/devops-assignment/actions/runs/38456443849)
passed with [two targets UP](../../evidence/ci/monitoring-38456443849/evidence/observability/prometheus-targets.png)
and [populated Grafana panels](../../evidence/ci/monitoring-38456443849/evidence/observability/grafana-dashboard.png).
The workflow deletes its disposable cluster after evidence.

CPU can be queried with rate(container_cpu_usage_seconds_total{namespace="kitledger"}[2m]);
memory with container_memory_working_set_bytes{namespace="kitledger"}. Container
logs are inspected with kubectl logs; /health and /ready separate process and
DB readiness. Alerting evaluates a condition over time and routes notifications;
custom alert firing/delivery was not executed (Alertmanager is disabled in this
small evidence environment).

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
