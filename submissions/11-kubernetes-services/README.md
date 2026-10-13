# Session 11: Kubernetes Networking & Services

Yash Agrawal · 24bcs10164

Source: [services.yaml](services.yaml), [verify.sh](verify.sh),
[FQDN](fqdn/README.md), [CoreDNS](coredns/README.md).

ClusterIP supplies an internal virtual address; NodePort exposes a node port;
LoadBalancer requests an implementation outside the Service; ExternalName creates
a DNS CNAME; a headless Service returns endpoint addresses rather than a virtual IP.
The Linux Minikube tunnel tests an actual local LoadBalancer implementation;
it is not an AWS cloud load balancer and creates no AWS cost.

A Deployment owns rollout revisions through ReplicaSets. ReplicaSets maintain
Pod counts but do not implement rolling-update history. A DaemonSet places
Pods on eligible nodes; a StatefulSet supplies stable identities and volume
association. Deployments fit interchangeable replicas, DaemonSets fit node agents,
and StatefulSets fit stateful identities. A ReplicaSet maintains instances;
a Service selects ready Pod endpoints and gives clients a stable address.

The first run resolved ExternalName successfully but its HTTP request returned
403 because DNS aliasing did not change the Host header. The corrected HTTPS
check uses curl --connect-to to preserve the destination Host and TLS SNI.
The root audit links the rerun; failed output is retained.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
