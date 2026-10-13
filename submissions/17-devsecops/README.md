# Session 17: Complete CI/CD & DevSecOps

Yash Agrawal · 24bcs10164

The [root workflow](../../.github/workflows/kitledger.yml) is a real DevSecOps
pipeline over the [KitLedger application](../../session21-python/README.md):
pytest → Ruff/Bandit SAST → pip-audit/npm audit SCA → full-history Gitleaks →
both Docker builds → both Trivy HIGH/CRITICAL gates → SHA-tagged GHCR images →
Helm deployment in disposable Minikube → PostgreSQL-backed browser checks.

The initial Debian runtime failed Trivy on util-linux and bundled packaging
dependencies. The corrected Alpine runtime upgrades OS packages and removes
unused pip/setuptools from the final image. No broad suppression or disabled
gate was used. Both scans pass in
[this real run](https://github.com/YashSensei/devops-assignment/actions/runs/38448892637).

Trivy checks known vulnerabilities in OS/language packages against its databases
at scan time. A clean result means no matching findings at the configured
severities; it does not prove absence of logic bugs, unknown CVEs or configuration
risks. A native Trivy job-log screenshot and registry access check remain explicit
evidence items. The local GitHub CLI lacks read:packages scope.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
