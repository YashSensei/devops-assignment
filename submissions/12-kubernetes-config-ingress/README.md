# Session 12: Kubernetes Ingress, ConfigMaps & Secrets

Yash Agrawal · 24bcs10164

Source: [config.yaml](config.yaml), [verify.sh](verify.sh).
The disposable workflow creates a fresh runtime Secret without publishing its
value, injects it alongside a ConfigMap, confirms presence in a Pod and tests
Ingress routing. ConfigMap environment changes affect new containers; existing
process environments remain unchanged. The corrected script verifies both states.

An Ingress is routing configuration. Its controller implements that configuration.
The example uses the Nginx controller supplied by Minikube; a manifest alone is
not an operating proxy. KitLedger routes / to frontend and /api to backend.

Base64 is encoding, not encryption. printf versus a newline-adding echo produces
different password bytes. The exercise uses a public dummy value for that
comparison and never exposes the generated runtime credential.
[Recorded first run](../../evidence/ci/kubernetes-38448657607/12-kubernetes-config-ingress.log);
the root audit distinguishes later corrected verification.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
