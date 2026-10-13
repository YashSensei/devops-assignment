# Evidence index

All results below are actual executions. No pass is inferred from configuration.
Dates in logs are UTC; 2026-10-13 evening UTC is 2026-10-14 IST.

## Executed runs

| Run | Revision | Result and evidence |
|---|---|---|
| [KitLedger 38450469520](https://github.com/YashSensei/devops-assignment/actions/runs/38450469520) | 78c9dc0a78584735c8c96be11b79697fc2036075 | PASS: 23 API tests, calculator tests, source/dependency/history scans, two Trivy image gates, GHCR SHA tags, Helm/PostgreSQL/Ingress and browser workflow |
| [Foundations 38450248504](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | 436f8129f35938813e937b067cb518eeea338667 | PASS: Linux/systemd/test user, cheat sheet, shell, networking namespace, Git, seven images, network/volume Compose; [logs](ci/foundations-38450248504/foundation-execution-evidence) |
| [Kubernetes 38450245721](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | 436f8129f35938813e937b067cb518eeea338667 | PASS: Sessions 10–15 scripts; [individual exits](ci/kubernetes-38450245721/results.txt), [logs](ci/kubernetes-38450245721) |
| [Kubernetes first attempt 38448657607](https://github.com/YashSensei/devops-assignment/actions/runs/38448657607) | 2bd2b1408ffd2c4935572dd9652a8dabb2a2b077 | FAILED: ExternalName HTTP Host/SNI and shortened DNS check; [original logs](ci/kubernetes-38448657607). Corrected retry above passed |
| [Monitoring first attempt 38449935009](https://github.com/YashSensei/devops-assignment/actions/runs/38449935009) | 0d27c527f0691ce64ad647fb2fd9ee307f4cac78 | FAILED: Grafana Deployment unavailable after Helm timeout; metrics/GitOps downstream steps did not pass |
| [Monitoring diagnostic retry 38451638002](https://github.com/YashSensei/devops-assignment/actions/runs/38451638002) | a521e9e0cc8358a646316b6935c03518698f2b4d | FAILED: [pod diagnostics](ci/monitoring-38451638002/evidence/observability/monitoring-describe.txt) show Grafana OOMKilled, exit 137, at 256Mi; fix raises limit to 768Mi and phases monitoring before Argo |

Older [capstone evidence](ci/capstone-38448892637) used a frontend Service
port-forward for the browser, although its curl request exercised Ingress.
Only the newer run above is labelled **browser through Ingress**.

## GitOps and monitoring verification

[GitOps run 38453774602](https://github.com/YashSensei/devops-assignment/actions/runs/38453774602)
passed on workflow revision 1811fb50945bde24b0e99200a5c626916b280e64. Argo initially
synced revision 8aebd24 with two replicas; commit 7ba1e85 introduced three and Argo
later synced revision 534e3a0 containing that change.
[Initial sync](ci/gitops-38453774602/evidence/observability/argocd-initial.txt),
[synced revision](ci/gitops-38453774602/evidence/observability/argocd-git-change.yaml),
[deliberate one-replica drift](ci/gitops-38453774602/evidence/observability/drift-before.txt)
and [three-replica recovery](ci/gitops-38453774602/evidence/observability/drift-healed.txt)
are retained. Argo application removal and cluster teardown passed.

Its old browser test checked panel titles but captured loading panels. That green
job does **not** prove populated Grafana panels. Stronger checks were added.
[Run 38454813958](https://github.com/YashSensei/devops-assignment/actions/runs/38454813958)
recorded [both backend targets UP](ci/monitoring-38454813958/evidence/observability/browser-verified-targets.json)
and a loaded Targets page, but failed because Grafana showed No data. Earlier
failure artifacts are retained separately.

**Final monitoring verification passed:** [run 38456443849](https://github.com/YashSensei/devops-assignment/actions/runs/38456443849),
source revision 5de16bccb1f65aa4dc71637746337ee2b824ff68, using the published
60c78265ac7f1db7fb2ddbe3b877584fd5a13e5d application images.
[Targets UP](ci/monitoring-38456443849/evidence/observability/prometheus-targets.png),
[populated Grafana](ci/monitoring-38456443849/evidence/observability/grafana-dashboard.png),
[verified target JSON](ci/monitoring-38456443849/evidence/observability/browser-verified-targets.json),
[positive Prometheus query](ci/monitoring-38456443849/evidence/observability/prometheus-query.json),
[Grafana requests/responses](ci/monitoring-38456443849/evidence/observability/grafana-query.json)
and [automated monitoring video](ci/monitoring-38456443849/automated-monitoring-workflow.webm)
are retained. The screenshots were visually inspected: the stat shows 193 real
requests, with populated short-run rate/latency/error panels. The earlier instant
query and later screenshot can differ as probes continue. This run intentionally
skipped GitOps because the separate run above already exercised that sequence.
Monitoring cluster teardown passed. No custom alert delivery was tested.

## Screenshots and video

Captured by automated Playwright in a disposable Linux Minikube environment,
using real PostgreSQL and Ingress controller traffic:

- [Desktop loan workflow](ci/capstone-38450469520/evidence/browser/desktop-loan.png).
- [Mobile after return to maintenance](ci/capstone-38450469520/evidence/browser/mobile-library.png).
- [Actual backend metrics](ci/capstone-38450469520/evidence/browser/metrics.png).
- [Automated PostgreSQL/Ingress workflow video](ci/capstone-38450469520/automated-postgresql-ingress-workflow.webm).
- [Pods/Services/Ingress](ci/capstone-38450469520/evidence/ci/kubernetes.txt) and
  [events](ci/capstone-38450469520/evidence/ci/events.txt).

[Green CI](github/green-run.png), [Git history](github/commit-history.png),
[backend package](github/backend-package.png) and [frontend package](github/frontend-package.png)
were captured with fresh unauthenticated Chrome. [Capture metadata](github/observations.json)
contains timestamps and visible page text. Both packages explicitly display Public
and full SHA tags. Anonymous registry manifests also returned HTTP 200 for SHA
60c78265ac7f1db7fb2ddbe3b877584fd5a13e5d. GitHub requires sign-in to view job logs,
so the Trivy job-log screenshot remains missing; the actual CLI log is archived.

These images were visually inspected. The metrics screenshot uses a backend
port-forward, not the public Ingress route. The application screenshots are
browser captures, not rendered terminal logs.

Supplemental **Windows local SQLite** run after Docker became unavailable:
[desktop](browser/desktop-loan.png), [mobile](browser/mobile-library.png),
[automated video](browser/automated-sqlite-workflow.webm).
This is not PostgreSQL, Compose or Kubernetes browser evidence.

## Commands and provenance

[Rendered pytest, Trivy and Kubernetes transcripts](rendered/README.md) make
selected authentic outputs easier to review. They are explicitly labelled as
rendered historical output, not native terminal/authenticated GitHub captures.
Their source hashes and rendering timestamps are retained separately.

[runs/](runs) contains timestamped JSON records from scripts/record.py:
UTC capture time, checkout revision, dirty state, environment, command, combined
actual output and exit code. For gh run retrievals, those outer fields describe
the retrieval operation. The linked Actions run's head SHA, runner timestamps
and job status identify the original execution; a retrieval exit zero alone
does not mean the historical CI run passed.

CI artifact directories retain their original logs. Commands and timestamps for
them are in the corresponding linked workflow/run. Full capstone job output is
also archived in the record whose name ends capstone-ci-38450469520.json, including
pytest, both Trivy scans, publication and cluster cleanup. Failed attempts are
retained separately, not edited to look like successful retries.

## Environment and limitations

- Windows 11 Home, 15.7 GiB RAM; Docker Desktop 4.43.2 / Engine 28.3.2.
  Initial Compose startup became healthy. Later disk pressure and Docker hangs
  blocked a fresh local run; no unrelated volumes/images were pruned.
- Python 3.13 isolated backend environment, Node 22; Linux CI uses Ubuntu runners.
- Windows Minikube reported unsupported Docker driver. Linux Minikube was
  explicitly approved. Local kind was not executed.
- In-app browser connection failed before navigation (missing sandboxPolicy).
  Automated Playwright with fresh contexts supplied real browser verification;
  no user's logged-in Chrome profile was used.
- API tests use isolated SQLite; PostgreSQL end-to-end behavior is verified
  separately by Kubernetes browser tests.
- Successful coursework run recorded actual scale-up to five, PVC persistence,
  readiness/liveness failures and recovery, OOMKilled and repairs.
  Explicit HPA scale-down-to-two evidence remains missing.
- Monitoring Targets UP and populated panels passed in the final run above.
  Earlier empty/loading screenshots remain historical failures, not final evidence.
- Required native screenshots of pytest/Compose/authenticated Trivy/Kubernetes CLI
  and a student-narrated live-update demo remain
  separately listed in [the audit](../ASSIGNMENT-COMPLETION.md).
- [Presentation outline](../session21-python/PRESENTATION.md) is prepared, not delivered.

## Cleanup and AWS

Successful capstone/coursework run cleanup steps deleted their named disposable
Minikube clusters. Monitoring workflows also have always-run cluster teardown.
No permanent deployment is promised.

AWS was omitted at the student's request. **No AWS resources were provisioned,
no project-created AWS resources remain, and no scheduled deletions exist.**
No AWS plan/apply/Console/destroy evidence is claimed. No AWS account-wide
inventory was performed; unrelated resources and billing are outside this claim.
