# Kubernetes storage

emptyDir exists for the lifetime of one Pod: container restarts preserve it,
Pod replacement does not. hostPath mounts a node directory and couples the
workload to that node; it can expose sensitive host files and is not a portable
general database solution.

A PersistentVolume represents storage; a PersistentVolumeClaim requests it.
A StorageClass selects a provisioner and parameters. Dynamic provisioning
creates a volume when a claim needs one, sometimes delaying until a consumer
is scheduled (WaitForFirstConsumer). ReclaimPolicy controls whether releasing
a claim deletes or retains the underlying storage.

The mini-project mounts a 500Mi RWO claim at /data. A real test writes the
student identity, deletes the Pod, and reads it through the replacement.
Multiple replicas sharing this claim are a single-node Minikube exercise:
ReadWriteOnce limits node attachment, not necessarily the number of Pods.
KitLedger uses exactly one PostgreSQL StatefulSet replica and a PGDATA
subdirectory. Application replicas connect over the Service and do not share
the database filesystem directly.
