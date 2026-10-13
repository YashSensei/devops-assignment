# Security scan scope and checksum exception

The pipeline retains pytest, source/dependency checks, full-history Gitleaks and
both Trivy HIGH/CRITICAL image gates. Clean scans are point-in-time tool results,
not proof of perfect security. No broad path exclusion or failing gate was disabled.

The final evidence staging scan reported 222 generic-api-key matches. Inspection
identified 216 Prometheus discovery metadata checksum values and six exact
kubectl annotation lines. All were 64-character SHA-256 values under
__meta_kubernetes_pod_annotation_checksum_secret or checksum/secret, not Secret
contents, passwords or authentication tokens. None was committed before review.

[.gitleaks.toml](.gitleaks.toml) extends all built-in rules and adds only two
generic-api-key exceptions, each requiring BOTH a narrow evidence filename/path
and the exact checksum field/format. JSON matching is restricted to the matched
field, not the whole JSON line; a different secret on that line is not exempted.
The describe exception matches an entire line containing only the checksum
annotation. No evidence directory, credential field or commit is globally ignored.

Recorded passwords were generated for disposable labs and masked or passed via
Kubernetes Secret references. No actual committed credential leak was found, so
no credential revocation is claimed to have occurred.

Recheck staged files with:

```sh
gitleaks git --pre-commit --staged --redact .
gitleaks git --redact .
```

Use the native staged scan so path restrictions are evaluated correctly; a raw
stdin diff lacks filenames. Treat any new match as a finding requiring review.
The real image scan reports are in Actions and [labelled rendered excerpts](evidence/rendered/README.md).
