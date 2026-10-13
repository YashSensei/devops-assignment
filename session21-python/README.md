# KitLedger — equipment loans

Yash Agrawal | 24bcs10164 | yash.24bcs10164@sst.scaler.com

[Repository](https://github.com/YashSensei/devops-assignment) ·
[CI](https://github.com/YashSensei/devops-assignment/actions/workflows/kitledger.yml) ·
[Evidence](../evidence/README.md) · [Audit](../ASSIGNMENT-COMPLETION.md) ·
[Presentation](PRESENTATION.md)

## Purpose and originality

KitLedger manages individually tagged equipment, lending and returns. Equipment
has a category, condition and notes. Loans record borrower, purpose, checkout,
due date and return date. Ready equipment is available only without an active loan.
Maintenance/retired assets cannot be lent; due dates must be within 30 days.
Returns can send equipment into maintenance. Assets with loan history must be
retired, not deleted. These tables and rules distinguish it from a renamed
TaskBoard or CampusFix. Attribution and AI assistance: [SOURCES.md](../SOURCES.md).

The responsive React UI provides equipment and loan views, search/status filters,
summary counts, dialogs and loading/empty/error states. Data is persisted, not
pre-filled activity.

## Architecture

```text
Browser -> Nginx / React -> /api -> FastAPI + SQLAlchemy -> PostgreSQL / PVC
                                      |
                                   /metrics -> Prometheus -> Grafana

main commit -> tests/scans -> images/Trivy -> GHCR SHA tags
                                         -> Helm / Minikube / browser / cleanup
```

Alembic creates equipment and loans tables. A database unique constraint prevents
two active loans per asset; PostgreSQL row locks protect state transitions.
An advisory lock serializes migrations across backend replicas.

| Endpoint | Behavior |
|---|---|
| GET/POST /api/equipment | Filter/list and create assets |
| GET/PUT/DELETE /api/equipment/{id} | Inspect, update, delete an unused asset |
| GET/POST /api/loans | List/filter and checkout |
| POST /api/loans/{id}/return | Return once, retaining history |
| GET /api/summary | Database-backed counts |
| GET /health | Process liveness |
| GET /ready | Database connectivity and equipment-schema readiness |
| GET /metrics | Request counters/latency with bounded route labels |

## Local start and stop

Requires a working Docker Linux engine and Compose. Run from this directory:

```powershell
powershell -File scripts/init-local.ps1
docker compose up --build -d --wait
docker compose ps
```

Open http://localhost:3000; backend health: http://localhost:8000/health.
The generated .env is ignored and preserved. PostgreSQL has no host-published
port. Health-based dependency ordering waits for DB/API readiness before Nginx.

```powershell
docker compose logs --tail 100 backend
docker compose down
```

Normal stop preserves the ledger-data volume. **Only to intentionally erase this
demo database**, run `docker compose down --volumes` from this directory.
Never use global Docker prune for project cleanup.

The three-service stack built and became healthy in a retained local run. Later
Docker calls stalled after disk pressure; newest images are verified by Linux CI,
not a claimed fresh local Compose/browser run.

## Tests and development

Python 3.13 is used in CI. From backend, create and activate an isolated venv:

```sh
python -m venv .venv
# PowerShell: .venv/Scripts/Activate.ps1
# Linux/macOS: source .venv/bin/activate
pip install -r requirements-dev.txt
pytest -v
ruff check app tests alembic
bandit -r app -ll
pip-audit -r requirements.txt
```

There are 23 API tests across health/readiness, equipment, loans, returns and
summary. Tests create isolated SQLite databases, including migrations/reopen
persistence checks; they never clear production data. PostgreSQL is separately
exercised by the real Kubernetes browser workflow.

From frontend, after starting the isolated demo:

```sh
npm ci
npm run build
npm audit --audit-level=high
npx playwright install chromium
npx playwright test
```

The browser test creates unique demo data and checks edit/checkout/return,
invalid/duplicate requests, reload persistence, filters, unused-asset deletion
and mobile layout. It intentionally preserves loan history. Never target a
production dataset. APP_URL selects the demo URL; PLAYWRIGHT_CHANNEL=chrome
can select an installed Chrome for testing in a fresh isolated context.

Supplemental local browser evidence used an explicitly selected SQLite file
after Docker failed. It is not labelled PostgreSQL or Kubernetes evidence.

## Images, CI and security

[The workflow](../.github/workflows/kitledger.yml) runs on main pushes and PRs:
pytest/Ruff/Bandit/pip-audit/npm audit/full-history Gitleaks; Terraform/Helm
validation; frontend and image builds; Trivy HIGH/CRITICAL gates; non-PR SHA-tagged
publication; real Helm deployment/browser tests; artifacts and cluster cleanup.

- Backend: ghcr.io/yashsensei/kitledger-backend:<full-commit-SHA>.
- Frontend: ghcr.io/yashsensei/kitledger-frontend:<full-commit-SHA>.
- Backend uses Python Alpine; frontend is Node-to-Nginx multi-stage.
  Both application containers run non-root.
- Initial image findings were fixed by changing the backend base and removing
  unused runtime packaging tools. No security gate was disabled.
- GHCR publication and anonymous registry manifests are verified. Public
  package screenshots in the evidence index show full SHA tags.

Scan output is in linked Actions jobs. Clean scans depend on current advisory
databases and do not prove absence of design flaws. The application has no user
authentication, authorization or TLS; restrict its exposure to a controlled lab.
See [the narrow Kubernetes checksum exception](../SECURITY-SCANS.md) for the
reviewed Gitleaks false-positive handling; all default rules remain enabled.

## Kubernetes and Helm

The chart includes PostgreSQL StatefulSet/PVC, two backend and two frontend
replicas, ClusterIP Services, ConfigMap, an externally supplied Secret, resources,
probes, Ingress / and /api, optional HPA and ServiceMonitor. When HPA is enabled
its template omits backend replicas to avoid competing ownership.

Use an explicitly selected disposable context. The workflow above is the complete
executed Linux bootstrap. Locally, load matching images or authenticate to GHCR,
apply k8s/namespace.yaml, then use scripts/k8s-secret.ps1 -Context YOUR_CONTEXT.
Install with both tags set to the tested full SHA:

```sh
helm upgrade --install kitledger helm/kitledger --kube-context YOUR_CONTEXT -n kitledger --set backend.tag=FULL_SHA,frontend.tag=FULL_SHA --wait --timeout 6m
kubectl --context YOUR_CONTEXT -n kitledger get pods,svc,ingress,pvc
helm --kube-context YOUR_CONTEXT list -n kitledger
```

Uppercase arguments are instructional placeholders, not claimed resources.
Ingress requires an installed Nginx controller and kitledger.local resolving to
its reachable address. CI uses a controller port-forward/hosts entry. A frontend
Service port-forward alone is not Ingress evidence. Metrics-server and CPU
requests are prerequisites for HPA; separate Session 13 runtime observations are
linked in the audit.

## Monitoring, GitOps and Terraform

monitoring/ supplies Prometheus/Grafana values and the app dashboard; gitops/
supplies the capstone Argo Application. The separate Session 20 workload
demonstrates Git-driven replicas/drift repair without competing with CI's Helm
owner. [Monitoring](https://github.com/YashSensei/devops-assignment/actions/runs/38456443849)
passed with two UP backend targets, positive query results and visibly populated
Grafana panels. [GitOps](https://github.com/YashSensei/devops-assignment/actions/runs/38453774602)
verified a committed 2-to-3 replica change and live 1-to-3 drift recovery.
Both temporary environments were removed. The evidence index preserves the earlier
OOM, startup and insufficient screenshot-wait failures separately.

terraform/ describes VPC, two public subnets, EKS/node group, IAM and storage
driver permissions with a safe example and tracked provider lockfile. Sessions
18/19 have separate S3 and network/EC2/S3 projects. All three passed CI
init/fmt/validate. **AWS execution is omitted at the student's request**: no
plan/apply, deployed AWS endpoint, Console screenshots or destroy is claimed.
Those remain missing runtime rubric requirements.

## Troubleshooting and cleanup

- Readiness 503: check database health, Secret URL and migration logs without
  printing credentials. Liveness may pass while readiness correctly fails.
- ImagePullBackOff: check full SHA, architecture and GHCR pull access.
- Ingress 404/502: inspect host/path, controller, selectors and EndpointSlices.
- HPA unknown: inspect metrics-server and CPU requests before load testing.
- Docker hang: check disk space/engine health; preserve unrelated volumes and credentials.
- Stop Argo reconciliation before deleting its workload. Uninstall only the
  selected release/namespace and explicitly review PVC deletion. CI deletes
  only its named disposable profile after evidence collection.

No AWS resources were created by this work, so no project-created AWS resources
await cleanup or scheduled deletion. No account-wide inventory was performed;
this says nothing about unrelated account resources.

## Evidence and student handoff

See [dated evidence](../evidence/README.md), [submission links](../SUBMISSION-GUIDE.md)
and [exact audit](../ASSIGNMENT-COMPLETION.md). Automated recordings are real tests,
not a student presentation. Yash must understand the implementation, narrate and
demonstrate a visible commit → green CI → updated deployment, address missing
screenshots and obtain acceptance of environment/cloud omissions.
The form has not been submitted. CI teardown leaves no permanent hosted website.
