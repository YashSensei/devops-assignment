# DevOps coursework and KitLedger

Yash Agrawal | 24bcs10164 | yash.24bcs10164@sst.scaler.com

[All 20 submission README links](SUBMISSION-GUIDE.md) ·
[Requirement audit](ASSIGNMENT-COMPLETION.md) · [Evidence](evidence/README.md) ·
[Sources and AI assistance](SOURCES.md)

KitLedger is an original equipment inventory and lending application. It manages
physical assets, availability, due dates, returns and maintenance while preserving
loan history. This repository also contains Linux, Git, Docker, Kubernetes,
CI/security, Terraform and observability coursework.

## Start KitLedger

Requires Docker Desktop with a working Linux engine, Compose and free disk space.
From the repository root in PowerShell:

```powershell
cd session21-python
powershell -File scripts/init-local.ps1
docker compose up --build -d --wait
docker compose ps
```

Open http://localhost:3000. The initialization script creates an ignored random
database password without printing it. Stop with `docker compose down`, preserving
the database volume. See the [capstone README](session21-python/README.md) for
architecture, tests, Kubernetes, troubleshooting and scoped cleanup.

## Verified work and limitations

- 23 isolated API tests, React build, source/dependency/Git-history scans.
- Both images, strict Trivy HIGH/CRITICAL gates, SHA-tagged GHCR publication,
  Helm deployment with PostgreSQL and 2 backend + 2 frontend replicas.
- Automated browser equipment/loan lifecycle, validation, filters, reload and
  mobile workflow. Supplemental local SQLite evidence is labelled separately.
- Linux/systemd, networking and Git exercises on disposable Linux runners; six
  Hello World images, the multi-stage image, and Docker network/volume lab.
- Terraform init/fmt/validate for three projects, not AWS deployments.

The [evidence index](evidence/README.md) identifies exact runs and remaining gaps.
The coursework is **not claimed 100% complete**. Required screenshots, some
extended observations and the student's narrated live-update presentation remain
independent obligations. Read the audit before submitting.

## Environment and cloud scope

Development: Windows 11, approximately 15.7 GiB RAM. Windows Minikube rejected its
Docker driver; approved Kubernetes exercises use disposable Linux GitHub Actions
Minikube. Instructor acceptance remains a student responsibility. Local Docker
later became unresponsive after disk pressure; a fresh local startup after that
failure is not claimed.

AWS is unnecessary for application tests. At the student's request Sessions 18/19
and capstone EKS remain **Terraform code and instructions only**. No AWS resources
were provisioned and this work incurred no AWS resource charges. AWS plan/apply,
Console and destroy evidence is missing; this decision does not alter the rubric.

## Delivery boundaries

This is a controlled teaching demo without user authentication, authorization,
TLS termination or production backups. Keep it on localhost or an isolated cluster.
Secrets, databases, Terraform state/plans and caches are excluded from Git.
Security gates remain enabled; clean scans are not proof of perfect security.

CI clusters are temporary and cleaned up; there is no permanent hosted website.
GHCR publication is verified, but anonymous visibility/instructor pull access
still needs checking. The [presentation outline](session21-python/PRESENTATION.md)
and automated recordings do not represent a student-delivered presentation.
