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

For the capstone chart, HPA owns backend replica count: its template omits replicas
when autoscaling is enabled, and Argo is configured to respect that field.
Argo and an independent Helm deployment job must not simultaneously own the same
long-lived release. The standalone teaching workload is deliberately separate.

Monitoring install, populated dashboards and real GitOps reconciliation are only
passed after their execution evidence is linked in the root audit. The workflow
always deletes the disposable cluster after collecting results.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
