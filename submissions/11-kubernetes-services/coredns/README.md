# CoreDNS

CoreDNS watches Kubernetes Services and EndpointSlices and answers cluster DNS
queries. Kubelet configures Pod resolver settings; requests reach the kube-dns
Service, then CoreDNS Pods. The kubernetes plugin serves cluster names and the
forward plugin usually passes other queries to upstream resolvers.

Inspect kubectl -n kube-system get configmap coredns -o yaml for the actual
Corefile. A typical configuration includes errors, health, ready, kubernetes,
prometheus, forward, cache and reload plugins.

Troubleshoot in layers: inspect Pod resolv.conf and dnsPolicy; query the Service
FQDN; check namespace spelling; inspect kube-dns Service/EndpointSlices and
CoreDNS Pods/logs; inspect NetworkPolicies and UDP/TCP 53 paths; compare external
and internal lookups. A missing Service has no expected DNS record, while an
empty headless Service may have no ready endpoint addresses.
