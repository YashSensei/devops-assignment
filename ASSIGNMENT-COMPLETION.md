# Requirement audit

Yash Agrawal · 24bcs10164 · yash.24bcs10164@sst.scaler.com

Audit date: 2026-10-13. Sources and pinned instructor revision: [SOURCES.md](SOURCES.md).
Statuses: **not started**, **implemented**, **executed-and-passed**, **failed**,
**blocked**, **student-only**. A row containing several requirements is complete
only when every constituent requirement has evidence; partial work stays explicit.
No grade or full completion is claimed.

| Session | Exact requirement / required scope | Implementation path | Verification command / action | Evidence link | Status |
|---|---|---|---|---|---|
| 1&2 | Links/inodes/original deletion; adduser vs useradd and temporary user; real systemd journal/service; Linux cheat sheets | [session2-linux](session2-linux/README.md) | See session README | [Index](evidence/README.md) | not started |
| 3 | System script: date, hostname, username, disk, processes, variables, read -p, mkdir, touch, > redirection; real output | [session3-shell-scripting](session3-shell-scripting/README.md) | See session README | [Index](evidence/README.md) | not started |
| 4 | Commands from instructor networking repositories/cheat sheet; interfaces/address/routing/DNS/ports/connectivity; explanations and actual output | [session4-networking](session4-networking/README.md) | See session README | [Index](evidence/README.md) | not started |
| 5 | commit -m versus -a -m; 2-4 main commits and 2-3 feature commits; selected cherry-pick; unselected changes absent; commands/graph | [session5-git-github](session5-git-github/README.md) | See session README | [Index](evidence/README.md) | not started |
| 6 | Six case-sensitive app folders: nodejs-app/python-app/java-app/Apache-app/React-app/nginx-app; build/run/request all endpoints | [session6-7-docker](session6-7-docker/README.md) | See session README | [Index](evidence/README.md) | not started |
| 7 | Multi-stage image at host 8080; required Hello World response; docker ps; identity; at least three application types | [session6-7-docker/multi-stage-dockerfile](session6-7-docker/multi-stage-dockerfile/README.md) | See session README | [Index](evidence/README.md) | not started |
| 8 | Frontend/backend/MySQL; three networks/backend on two; connectivity/isolation; Apache host port 80; live Nginx bind edit; volumes and multi-host overlay | [session8-docker-networking-volume](session8-docker-networking-volume/README.md) | See session README | [Index](evidence/README.md) | not started |
| 9 | Install/configure Minikube, cluster status, architecture, all Kubernetes Basics exercises with outputs/screenshots | [submissions/09-kubernetes-fundamentals](submissions/09-kubernetes-fundamentals/README.md) | See session README | [Index](evidence/README.md) | not started |
| 10 | Rolling update, blue-green, canary traffic, Recreate; apply and explain every supplied Pod lifecycle YAML; ReplicaSet replacement | [submissions/10-kubernetes-core-objects](submissions/10-kubernetes-core-objects/README.md) | See session README | [Index](evidence/README.md) | not started |
| 11 | ClusterIP/NodePort/LoadBalancer/ExternalName/headless connectivity; object comparisons; FQDN and CoreDNS documentation, endpoints and DNS | [submissions/11-kubernetes-services](submissions/11-kubernetes-services/README.md) | See session README | [Index](evidence/README.md) | not started |
| 12 | ConfigMap/Secret inject/verify; Ingress/controller routing; newline Secret bug; ConfigMap changes need Pod restart; before/after troubleshooting | [submissions/12-kubernetes-config-ingress](submissions/12-kubernetes-config-ingress/README.md) | See session README | [Index](evidence/README.md) | not started |
| 13 | emptyDir/hostPath/PV/PVC/StorageClass/dynamic provisioning; supplied PVC /data mini-project; 2-5 replica HPA at 50%, load, CPU, scale up/down; probes | [submissions/13-storage-hpa-probes](submissions/13-storage-hpa-probes/README.md) | See session README | [Index](evidence/README.md) | not started |
| 14 | get/describe/logs/exec/events/explain/top/wide; CrashLoopBackOff, image errors, Pending, ContainerCreating, Service/DNS/network/config/OOM; supplied Nginx mini-project before/after | [submissions/14-troubleshooting](submissions/14-troubleshooting/README.md) | See session README | [Index](evidence/README.md) | not started |
| 15 | create/install/list/status/get/upgrade/history/rollback/uninstall/repo/search; Notes chart mini-project; install-upgrade-verify-bad upgrade-verify-rollback-verify | [submissions/15-helm](submissions/15-helm/README.md) | See session README | [Index](evidence/README.md) | not started |
| 16 | Demo application, Dockerfile, root workflow; tests/build/security/artifact/delivery; CI/CD and workflow/jobs/steps/runners/secrets explanation | [submissions/16-cicd](submissions/16-cicd/README.md) | See session README | [Index](evidence/README.md) | not started |
| 17 | Tests, SAST, SCA, secret scan, image build/scan/security gates, registry, real Kubernetes deployment and green pipeline | [submissions/17-devsecops](submissions/17-devsecops/README.md) | See session README | [Index](evidence/README.md) | not started |
| 18 | Private encrypted versioned S3; init/fmt/validate/plan/apply/show/output/destroy; IAM/EC2/S3/VPC/DynamoDB/RDS research | [submissions/18-terraform](submissions/18-terraform/README.md) | See session README | [Index](evidence/README.md) | not started |
| 19 | Providers/variables/resources/outputs/dependencies/state; VPC/subnet/SG/EC2/S3; architecture; plan/apply/service verification/console screenshots/destroy | [submissions/19-cloud](submissions/19-cloud/README.md) | See session README | [Index](evidence/README.md) | not started |
| 20 | Metrics/logs/alerts/CPU/memory/health, three observability pillars; Prometheus/Grafana; Argo CD two-replica mini-project, Git scale change, drift/self-heal | [submissions/20-monitoring-gitops](submissions/20-monitoring-gitops/README.md) | See session README | [Index](evidence/README.md) | not started |
| 21 | Original full-stack app, tests, Docker, CI/security/GHCR, Terraform EKS, Helm/Kubernetes, monitoring/GitOps, failure diagnosis, live-update presentation | [session21-python](session21-python/README.md) | See session README | [Index](evidence/README.md) | not started |

## Capstone rubric (live weights verified)

| Module | Exact criteria | Points | Evidence needed | Status |
|---|---|---:|---|---|
| M1 | FastAPI /health (2); GET/POST/PUT/DELETE (3); PostgreSQL/Alembic table (2); API frontend (2); responsive UI (1) | 10 | browser and database-backed operations | not started |
| M2 | pytest passes (3); 5 tests/3 endpoints (4); isolated DB/mock (2); pytest.ini/conftest (1) | 10 | pytest screenshot | not started |
| M3 | Public repo/instructor access (2); meaningful commits (2); gitignore (1) | 5 | history screenshot with at least 10 meaningful commits | implemented: initial repository only |
| M4 | Backend build (2); Node-to-Nginx multi-stage frontend (3); non-root (2); three-service Compose (3) | 10 | Compose output and localhost:3000 screenshot | not started |
| M5 | workflow (1); main trigger (1); pytest gate (3); frontend build (2); both image builds (3); GHCR (3); SHA tags (2) | 15 | green run URL and package screenshots | not started |
| M6 | Trivy both images (3); HIGH/CRITICAL failure (1); explain scan/CVE (1) | 5 | actual Trivy job screenshot and explanation | not started |
| M7 | HCL (2); init (1); nonempty plan (2); two-public-subnet VPC (3); EKS/node group (4); destroy (2); safe example (1) | 15 | plan, AWS Console VPC/EKS, destroy screenshots | blocked: account/region/budget approval |
| M8 | namespace (1); complete Helm chart (3); deployed release (3); 2+2 replicas (2); ClusterIP (2); / and /api Ingress (2); Running Pods (2) | 15 | pods/services/helm list and Ingress browser screenshots | not started |
| M9 | metrics (2); cluster Prometheus scraping (3); Grafana (2); populated app panel (3) | 10 | metrics, Targets UP, populated dashboard screenshots | not started |
| M10 | Root README (2); live commit-pipeline-deployment update (3) | 5 | narrated student presentation/live demo | student-only: presentation |

## Further explicit obligations

- Course Linux cheat sheets include PDF resources: command coverage must be audited after extracting these, not assumed from the abbreviated brief.
- Session 10 supplies twelve Pod lifecycle manifests, including init/multi-container and termination exercises.
- Session 12 includes the Secret newline bug and ConfigMap environment refresh after rolling restart.
- Session 13 mini-project specifies /data persistence, a 500Mi claim, 2–5 replicas, and 50% CPU; capstone persistence alone does not replace it.
- Session 15 Notes chart explicitly includes a deliberately bad image upgrade followed by rollback.
- Session 19 course mini-project begins with a network-only apply; the homework/user brief additionally requests EC2/S3. Billable phases need separate approval.
- Session 20 mini-project requires a committed replica change then deliberate drift recovery. Argo Application bootstrap stays outside its watched workload path.
- Required screenshots, browser CRUD/mobile/reload checks, AWS console evidence, security explanation, live-update demo, cleanup and final form submission are independently tracked, even when CLI checks pass.
