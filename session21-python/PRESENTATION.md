# KitLedger presentation outline

Prepared outline only: Yash Agrawal has not yet delivered a presentation through
this work. Automated test video is not a narrated student presentation.

1. Explain the equipment-loan problem, original schema and lending rules.
2. Open the app, add equipment, check it out, show that double checkout is blocked,
   return it needing maintenance, search/filter it, and reload persisted state.
3. Explain equipment/loans tables, active-loan unique constraint and Alembic.
4. Show passing tests and one rejected request. Explain isolated test databases.
5. Show Compose and non-root images; distinguish liveness from DB readiness.
6. Commit a visible UI change with a meaningful message. Push main and display
   the actual green pipeline, both Trivy logs and both SHA-tagged GHCR images.
7. Update the deployment to those exact images (through the chosen deployment
   owner), wait for rollout, and show the visible UI change through Ingress.
   The old browser video alone does not satisfy this sequence.
8. Explain namespace, replicas, Services, Ingress controller, PVC, probes and HPA.
9. Generate traffic; show actual /metrics, Prometheus Targets UP and a populated
   Grafana panel. Explain what a clean scan does and does not establish.
10. Explain Terraform VPC/EKS/node group and storage identity. Capture authenticated
    AWS Console screenshots while approved resources still exist.
11. Break and diagnose an image or Service selector, then show repaired traffic.
12. Suspend GitOps and demonstrate scoped cleanup. Keep destroy evidence.

Before paid labs: schedule the console screenshots and presentation recording;
confirm account, region, resource counts, hourly/total estimate and runtime.
After teardown there is no permanent cloud website to promise.

Suggested narration: 8–12 minutes, followed by questions. Explain in your own
words why returning equipment preserves history, why migrations are serialized,
why readiness checks the DB, and why CI security failure prevents publication.
