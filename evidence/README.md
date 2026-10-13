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
| [Monitoring diagnostic retry 38451638002](https://github.com/YashSensei/devops-assignment/actions/runs/38451638002) | a521e9e | See current run; diagnostics added before cleanup, not pre-labelled successful |

Older [capstone evidence](ci/capstone-38448892637) used a frontend Service
port-forward for the browser, although its curl request exercised Ingress.
Only the newer run above is labelled **browser through Ingress**.

## Screenshots and video

Captured by automated Playwright in a disposable Linux Minikube environment,
using real PostgreSQL and Ingress controller traffic:

- [Desktop loan workflow](ci/capstone-38450469520/evidence/browser/desktop-loan.png).
- [Mobile after return to maintenance](ci/capstone-38450469520/evidence/browser/mobile-library.png).
- [Actual backend metrics](ci/capstone-38450469520/evidence/browser/metrics.png).
- [Automated PostgreSQL/Ingress workflow video](ci/capstone-38450469520/automated-postgresql-ingress-workflow.webm).
- [Pods/Services/Ingress](ci/capstone-38450469520/evidence/ci/kubernetes.txt) and
  [events](ci/capstone-38450469520/evidence/ci/events.txt).

These images were visually inspected. The metrics screenshot uses a backend
port-forward, not the public Ingress route. The application screenshots are
browser captures, not rendered terminal logs.

Supplemental **Windows local SQLite** run after Docker became unavailable:
[desktop](browser/desktop-loan.png), [mobile](browser/mobile-library.png),
[automated video](browser/automated-sqlite-workflow.webm).
This is not PostgreSQL, Compose or Kubernetes browser evidence.

## Commands and provenance

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
- Monitoring install must pass before claiming Targets UP/populated Grafana.
- Required native screenshots of pytest/Git/Compose/CI/Trivy/GHCR/Kubernetes CLI,
  package instructor access and a student-narrated live-update demo remain
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
