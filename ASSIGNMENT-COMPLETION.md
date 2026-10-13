# Requirement audit

Yash Agrawal | 24bcs10164 | yash.24bcs10164@sst.scaler.com

Requirements read 2026-10-13; evidence updated 2026-10-14 IST. Official homework,
complete rubric, session mini-projects and extracted cheat sheets are recorded in
[SOURCES.md](SOURCES.md). No grade or full-completion claim is made.

Statuses distinguish **implemented**, **executed-and-passed**, **failed**,
**not executed**, **blocked** and **student-only**. A passing script does not
establish that every required screenshot or untested extension is complete.
AWS execution was omitted at the student's request, not silently substituted.

| Session | Exact requirement / required scope | Implementation path | Verification command / action | Evidence | Status |
|---|---|---|---|---|---|
| 1&2 | Links/inodes/original deletion; adduser vs useradd and temporary user; real systemd journal/service; Linux cheat sheets | [README](session2-linux/README.md) | bash session2-linux/{links,systemd-user,cheat-sheet}.sh (run individually) | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | executed-and-passed: links, test user/systemd, scripted cheat sheet; student-only: interactive/admin commands and native screenshots |
| 3 | System script: date, hostname, username, disk, processes, variables, read -p, mkdir, touch, > redirection; real output | [README](session3-shell-scripting/README.md) | printf 'coursework\\n' then bash session3-shell-scripting/system-info.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | executed-and-passed: script/input/output; native screenshot remains |
| 4 | Commands from instructor networking repositories/cheat sheet; interfaces/address/routing/DNS/ports/connectivity; explanations and actual output | [README](session4-networking/README.md) | bash session4-networking/network.sh; bash session4-networking/isolated-ip.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | executed-and-passed: observations and isolated IP changes; unavailable probes documented, hardware/interactive exercises not executed |
| 5 | commit -m versus -a -m; 2-4 main commits and 2-3 feature commits; selected cherry-pick; unselected changes absent; commands/graph | [README](session5-git-github/README.md) | bash session5-git-github/demo.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | executed-and-passed: isolated history/cherry-pick; native history screenshot remains |
| 6 | Six case-sensitive app folders: nodejs-app/python-app/java-app/Apache-app/React-app/nginx-app; build/run/request all endpoints | [README](session6-7-docker/README.md) | bash session6-7-docker/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | executed-and-passed: all six images/endpoints; native screenshots remain |
| 7 | Multi-stage image at host 8080; required Hello World response; docker ps; identity; at least three application types | [README](session6-7-docker/multi-stage-dockerfile/README.md) | bash session6-7-docker/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | executed-and-passed: separate multi-stage image/8080 response and docker ps; native screenshot remains |
| 8 | Frontend/backend/MySQL; three networks/backend on two; connectivity/isolation; Apache host port 80; live Nginx bind edit; volumes and multi-host overlay | [README](session8-docker-networking-volume/README.md) | bash session8-docker-networking-volume/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450248504) | executed-and-passed: Compose/network/isolation/persistence/bind mount/host network; multi-host overlay is explained, not deployed |
| 9 | Install/configure Minikube, cluster status, architecture, all Kubernetes Basics exercises with outputs/screenshots | [README](submissions/09-kubernetes-fundamentals/README.md) | minikube status -p coursework; kubectl get nodes | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | executed-and-passed: Linux Minikube/core exercises; student-only: tutorial screenshots and acceptance of environment |
| 10 | Rolling update, blue-green, canary traffic, Recreate; apply and explain every supplied Pod lifecycle YAML; ReplicaSet replacement | [README](submissions/10-kubernetes-core-objects/README.md) | bash submissions/10-kubernetes-core-objects/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | executed-and-passed: scripted rollout/rollback, replacement, strategies and 12 lifecycle examples; replica ratio is not exact traffic share |
| 11 | ClusterIP/NodePort/LoadBalancer/ExternalName/headless connectivity; object comparisons; FQDN and CoreDNS documentation, endpoints and DNS | [README](submissions/11-kubernetes-services/README.md) | bash submissions/11-kubernetes-services/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | executed-and-passed: five service types including Minikube tunnel; not an AWS load balancer; docs present |
| 12 | ConfigMap/Secret inject/verify; Ingress/controller routing; newline Secret bug; ConfigMap changes need Pod restart; before/after troubleshooting | [README](submissions/12-kubernetes-config-ingress/README.md) | bash submissions/12-kubernetes-config-ingress/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | executed-and-passed: injected config, Ingress and specified repairs; only demonstration secrets used |
| 13 | emptyDir/hostPath/PV/PVC/StorageClass/dynamic provisioning; supplied PVC /data mini-project; 2-5 replica HPA at 50%, load, CPU, scale up/down; probes | [README](submissions/13-storage-hpa-probes/README.md) | bash submissions/13-storage-hpa-probes/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | executed-and-passed: persistence, CPU/HPA scale-up and probes; not executed: recorded return to two replicas |
| 14 | get/describe/logs/exec/events/explain/top/wide; CrashLoopBackOff, image errors, Pending, ContainerCreating, Service/DNS/network/config/OOM; supplied Nginx mini-project before/after | [README](submissions/14-troubleshooting/README.md) | bash submissions/14-troubleshooting/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | executed-and-passed: errors, DNS/selectors, Pending, missing volume and actual OOMKilled repairs |
| 15 | create/install/list/status/get/upgrade/history/rollback/uninstall/repo/search; Notes chart mini-project; install-upgrade-verify-bad upgrade-verify-rollback-verify | [README](submissions/15-helm/README.md) | bash submissions/15-helm/verify.sh | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450245721) | executed-and-passed: Notes install/upgrades/bad image/rollback and Helm commands |
| 16 | Demo application, Dockerfile, root workflow; tests/build/security/artifact/delivery; CI/CD and workflow/jobs/steps/runners/secrets explanation | [README](submissions/16-cicd/README.md) | pytest submissions/16-cicd/tests; see root workflow | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450469520) | executed-and-passed: calculator tests and capstone pipeline/artifact/delivery; implemented: separate calculator Dockerfile, not executed |
| 17 | Tests, SAST, SCA, secret scan, image build/scan/security gates, registry, real Kubernetes deployment and green pipeline | [README](submissions/17-devsecops/README.md) | gh workflow run kitledger.yml | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450469520) | executed-and-passed: full security-gated pipeline; student-only: native scan/run screenshots |
| 18 | Private encrypted versioned S3; init/fmt/validate/plan/apply/show/output/destroy; IAM/EC2/S3/VPC/DynamoDB/RDS research | [README](submissions/18-terraform/README.md) | terraform init -backend=false; terraform fmt -check; terraform validate | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450469520) | implemented; CI init/fmt/validate passed; not executed: AWS plan/apply/show/output/destroy, omitted at student request |
| 19 | Providers/variables/resources/outputs/dependencies/state; VPC/subnet/SG/EC2/S3; architecture; plan/apply/service verification/console screenshots/destroy | [README](submissions/19-cloud/README.md) | terraform init -backend=false; terraform fmt -check; terraform validate | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450469520) | implemented; CI init/fmt/validate passed; not executed: AWS plan/apply/service/Console/destroy, omitted at student request |
| 20 | Metrics/logs/alerts/CPU/memory/health, three observability pillars; Prometheus/Grafana; Argo CD two-replica mini-project, Git scale change, drift/self-heal | [README](submissions/20-monitoring-gitops/README.md) | gh workflow run observability.yml -f image_tag=FULL_SHA | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38449935009) | implemented; failed: Grafana readiness timeout in first runtime attempt; diagnostic retry tracked in evidence index; GitOps not yet executed |
| 21 | Original full-stack app, tests, Docker, CI/security/GHCR, Terraform EKS, Helm/Kubernetes, monitoring/GitOps, failure diagnosis, live-update presentation | [README](session21-python/README.md) | pytest -v; npm run build; root KitLedger workflow | [Run](https://github.com/YashSensei/devops-assignment/actions/runs/38450469520) | implemented and partly executed-and-passed; see individual rubric rows below |

## Capstone rubric — verified weights

| Module | Exact criteria | Points | Current evidence / status |
|---|---|---:|---|
| M1 | FastAPI /health (2); CRUD (3); PostgreSQL/Alembic (2); API frontend (2); responsive UI (1) | 10 | executed-and-passed: PostgreSQL browser lifecycle, desktop/mobile and Ingress in [capstone run](https://github.com/YashSensei/devops-assignment/actions/runs/38450469520) |
| M2 | pytest (3); five tests/three endpoints (4); isolation (2); pytest.ini/conftest (1) | 10 | executed-and-passed: 23 isolated tests; [actual local output](evidence/runs/20261013T181937583957Z-pytest.json); native pytest screenshot missing |
| M3 | Public/instructor-accessible repo (2); meaningful commits (2); gitignore (1) | 5 | implemented and published; real history; native history screenshot missing |
| M4 | Backend image (2); multi-stage frontend (3); non-root (2); Compose (3) | 10 | executed-and-passed: CI images/non-root; [local Compose](evidence/runs/20261013T182037035663Z-compose-start.json) became healthy; newest-image local rerun/localhost:3000 screenshot missing after Docker failure |
| M5 | Workflow (1); main trigger (1); pytest gate (3); frontend (2); both images (3); GHCR (3); SHA tags (2) | 15 | executed-and-passed: green pipeline/SHA publication; GHCR pages and anonymous instructor pull access unverified |
| M6 | Both Trivy scans (3); HIGH/CRITICAL failure (1); explanation (1) | 5 | executed-and-passed: actual scan jobs and remediation, no gate disabled; native job-log screenshot missing |
| M7 | HCL (2); init (1); plan (2); two-public-subnet VPC (3); EKS/node group (4); destroy (2); safe example (1) | 15 | implemented; init/fmt/validate passed; AWS plan/apply/Console/destroy NOT EXECUTED at student's request |
| M8 | Namespace (1); chart (3); release (3); 2+2 replicas (2); ClusterIP (2); / and /api Ingress (2); Running Pods (2) | 15 | executed-and-passed on Linux Minikube; [resources](evidence/ci/capstone-38450469520/evidence/ci/kubernetes.txt), browser screenshots; native pods/services/helm screenshots missing |
| M9 | Metrics (2); scraping (3); Grafana (2); populated panel (3) | 10 | metrics executed-and-passed; monitoring install failed with Grafana timeout; runtime retry tracked separately |
| M10 | README (2); live commit-pipeline-deployment demo (3) | 5 | implemented: documentation and [outline](session21-python/PRESENTATION.md); student-only: narrated visible-update demonstration |

## Detailed gaps and evidence boundaries

- Linux PDF coverage: scripted file/permission/process/system/network commands
  ran; interactive htop/less/history, password administration, visudo, SSH/SCP
  and distro-specific yum remain student practice. The docs do not assert these ran.
- Networking records per-command observations; ping/traceroute failures do not
  contradict successful HTTPS. Physical interface/driver operations were not done.
- Session 9 uses the approved disposable Linux Minikube environment. Local kind
  was not executed because of disk pressure/Docker health. Complete any required
  tutorial-specific screenshots and confirm instructor acceptance.
- Session 10 uses a 3:1 canary replica mix; finite requests do not guarantee 25%.
  Deliberately failed lifecycle Pods are teaching observations, not unnoticed errors.
- Session 11 LoadBalancer uses a real Minikube tunnel request, not a cloud LB.
  The initial ExternalName Host/SNI failure and DNS failure are preserved in
  [the failed first coursework run](evidence/ci/kubernetes-38448657607).
  The corrected rerun passed all six scripts.
- Session 13 recorded PVC persistence and HPA scale-up to five plus probe recovery;
  return to two replicas was not explicitly awaited and verified.
- Session 14 evidence shows actual OOMKilled at 32Mi and successful 256Mi repair,
  FailedScheduling, missing ConfigMap/FailedMount, image failures and service/DNS fixes.
- Session 15 exercised a deliberately bad image and rollback; lint alone was not
  substituted for deployment.
- Session 16's small calculator Dockerfile exists but has no separate container
  execution claim. KitLedger's complete tested delivery pipeline is real.
- Monitoring/GitOps results must be checked against the latest evidence index.
  Do not infer Prometheus UP, populated Grafana or self-healing from manifests.
- Required native screenshots of tests, Git history, Compose, CI/security logs,
  package pages and Kubernetes CLI remain separate from text logs and automated
  application screenshots. AWS screenshots cannot be produced without deployment.
- Automated videos are not a delivered presentation. The visible UI change →
  green pipeline → newly deployed UI sequence must be narrated by the student.
- No AWS resources were provisioned; no destroy was needed or claimed. No
  account-wide audit of unrelated AWS resources was performed.
- Student must review institutional AI policy, understand the work, address
  omissions with the instructor and submit the form. This agent did not submit it.

All 20 submission targets are mapped in [SUBMISSION-GUIDE.md](SUBMISSION-GUIDE.md).
