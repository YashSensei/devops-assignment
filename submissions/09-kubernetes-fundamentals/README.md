# Session 9: Kubernetes Fundamentals

Yash Agrawal · 24bcs10164

Linux Minikube runs in disposable GitHub Actions VMs.
The Windows v1.39 Docker driver returned DRV_UNSUPPORTED_OS; the student approved
Linux Minikube plus a separate local kind option. Local kind is still blocked by
low disk space/Docker responsiveness and is not claimed as executed.

The API server accepts desired state; etcd stores it; scheduler assigns Pods;
controllers reconcile them; kubelet/container runtime run containers; networking,
CoreDNS and Services provide connectivity. Nodes and the control plane are
distinct responsibilities even in a single-node teaching cluster.

The workflows run minikube start/status, kubectl get nodes, namespace creation,
deployment, inspection, service exposure, scaling and updates. See the
[green capstone Minikube run](https://github.com/YashSensei/devops-assignment/actions/runs/38448892637)
and the [coursework workflow](../../.github/workflows/kubernetes-labs.yml).
Review the official Kubernetes Basics tutorial and provide any instructor-required
tutorial screenshots separately.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
