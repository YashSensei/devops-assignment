# Rendered historical transcripts

These images are **rendered excerpts of authentic saved output**, not native
terminal captures or authenticated GitHub job-log screenshots. Headers explicitly
state that distinction. No names, timestamps or results were changed. ANSI colour
escapes and repeated job/step prefixes are removed for readability; CI scan
sections are report-summary excerpts within the configured HIGH/CRITICAL filter.

- [Passing API tests](pytest.png).
- [Backend Trivy scan](trivy-backend.png).
- [Frontend Trivy scan](trivy-frontend.png).
- [Minikube resources](kubernetes.png).

[Provenance](provenance.json) records source paths, LF-normalized UTF-8 source
SHA-256 hashes and rendering
times. Source execution/retrieval dates remain in the original records. These are
supplemental review aids; obtain instructor acceptance if substituting them for
required native terminal or authenticated job-log screenshots.
