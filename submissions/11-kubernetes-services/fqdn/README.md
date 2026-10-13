# Kubernetes fully qualified domain names

A fully qualified domain name specifies the complete DNS hierarchy.
For a Service the usual form is service.namespace.svc.cluster.local, for example
web.coursework.svc.cluster.local. The cluster domain is configurable, so inspect
the Pod's resolv.conf instead of assuming every cluster uses cluster.local.

Within coursework, web resolves through the namespace search suffix. A Pod in
another namespace should use web.coursework or the complete FQDN. A ClusterIP
Service normally resolves to its virtual IP; a headless Service resolves to
individual ready backend addresses. An ExternalName Service supplies a CNAME
and does not create a proxy or change HTTP Host/TLS server names.

Verify with an actual client Pod: nslookup web.coursework.svc.cluster.local,
cat /etc/resolv.conf, then wget http://web.coursework.svc.cluster.local.
DNS resolution and application HTTP connectivity are separate checks.
