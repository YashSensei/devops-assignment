# Bug and concurrency review

Reviewed 2026-10-14 IST. Scope: application/API, database/migrations, browser state,
Docker/Helm, CI/GitOps, Terraform and coursework verification scripts. This is a
targeted engineering review, not a guarantee of zero bugs or a penetration test.
Earlier evidence remains historical; new checks do not rewrite it.

## Fixed findings

| Finding | Fix and regression coverage |
|---|---|
| Stale equipment forms silently overwrote newer edits | Additive migration `0002`, row versions, required version on PUT, 409 conflict; sequential stale-edit and real PostgreSQL simultaneous-editor tests |
| Slow old browser refresh could replace newer data | Abort previous fetches plus generation check, including a browser regression that deliberately ignores cancellation |
| Repeated submit events could issue duplicate mutations | Synchronous in-flight guard; browser test sends two submit events |
| N+1 reads and mixed summary snapshots during checkout/return | SQL joins, EXISTS and single-statement summary; query-count regressions |
| Mutation response read after releasing transaction locks | Serialize after flush but before commit; return only after successful commit |
| Readiness passed with missing loans table/columns | Query both mapped schemas, including version; regression drops loans |
| Unhandled 500s were missing from metrics; arbitrary method labels were unbounded | Record status in finally and normalize nonstandard methods |
| SQLite tests silently allowed broken foreign keys | Enable FK enforcement per connection; orphan-insert regression |
| Oversized identifiers reached database integer conversion | Validate IDs against the database's positive signed INTEGER range |
| Container shell swallowed normal server shutdown signals | Use `exec uvicorn` so the API receives SIGTERM as PID 1 |
| GitOps rerun expected two replicas from main after main already contained three | Replay authentic immutable two-replica revision then the workflow SHA; assert synced revision before drift test |
| Session 8 changes did not trigger foundation CI | Include its directory in workflow path filters |
| Local E2E screenshots overwrote historical tracked evidence | Default new captures to ignored test-results; CI explicitly selects its artifact directory |
| Concurrent .env initialization could overwrite credentials | Atomic CreateNew and preservation of an existing file |
| Modal keyboard focus escaped to background controls | Trap Tab/Shift+Tab, restore opener, preserve Escape/save behavior; browser regression |

## Verification

Seven new assertions were executed against the pre-fix API and failed as expected
(readiness, foreign keys, 500 metrics, three query/snapshot checks, stale edits).
The same regressions passed after the fixes. Local UI regressions passed in fresh
Chrome using controlled network fixtures; these are not PostgreSQL evidence.

The root KitLedger workflow now starts a separate, disposable loopback PostgreSQL
test service. Each concurrency test owns a random schema and removes only that
schema. Tests cover eight competing checkouts, competing returns, checkout versus
maintenance, competing editors, delete versus checkout, and simultaneous replica
migrations. Without TEST_POSTGRES_URL these tests explicitly skip, never silently
substitute SQLite. The existing Ingress browser lifecycle runs separately against
the deployed PostgreSQL application. Consult the exact revision's Actions run for
results; a local skip is not a pass.

## Upgrade note

Deploy both images at the same reviewed SHA and let the migration complete. PUT
clients must include the `version` returned by GET; on 409, refresh and reconcile
the user's edits. Existing equipment data is preserved. An already-open old
frontend needs a reload after this API change. Do not erase a database to migrate.

## Remaining boundaries

- Lab-only application: no login/roles, public TLS termination, rate limiting,
  pagination, backup/restore automation or mutation idempotency keys. Do not expose
  it as a public multi-user production service or store sensitive borrower data.
- A mutation timeout has an unknown outcome: refresh before retrying. Checkout,
  return and asset-tag constraints limit duplicates but are not universal request
  idempotency. Optimistic concurrency applies to equipment edits, not every HTTP
  operation.
- PostgreSQL is the concurrency target. SQLite is for isolated unit tests and the
  explicitly labelled supplemental local demo; its locking semantics differ.
- Individual API responses are consistent snapshots; separate browser requests
  are not a single global transaction. Refresh reconciles concurrent users' work.
- Local Docker remains unresponsive; no new local Compose pass is claimed.
  Browser-plugin connection failed before navigation; fresh standalone Playwright
  supplies browser regression testing.
- AWS remains unprovisioned at the student's request. Static Terraform validation
  cannot prove cloud permissions, networking, teardown or spending behavior.
- Coursework scripts assume the documented disposable Linux lab and include
  deliberately failing resources. Some teaching checks still record observations
  rather than asserting every intermediate state. Existing rubric gaps remain in
  ASSIGNMENT-COMPLETION.md; this review does not turn them into passes.
- GitOps replay verifies reconciliation of existing authentic commits, not a newly
  delivered, narrated student presentation.
