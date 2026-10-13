#!/usr/bin/env bash
set -euxo pipefail
kubectl get pods -n coursework -o wide
kubectl describe deployment web -n coursework
kubectl logs deployment/web -n coursework
kubectl exec deployment/web -n coursework -- nginx -t
kubectl events -n coursework
kubectl explain pod.spec.containers
kubectl top pods -n coursework
kubectl run bad-image -n coursework --image=nginx:kitledger-intentional-missing-tag --restart=Never
sleep 20
kubectl describe pod bad-image -n coursework
kubectl set image pod/bad-image -n coursework bad-image=nginx:stable-alpine
kubectl wait -n coursework --for=condition=Ready pod/bad-image --timeout=180s
kubectl run crash -n coursework --image=alpine:3.22 --restart=Never -- sh -c 'echo deliberate-exit; exit 1'
sleep 10
kubectl logs crash -n coursework
kubectl describe pod crash -n coursework
kubectl delete pod crash -n coursework
kubectl run crash -n coursework --image=alpine:3.22 --restart=Never -- sleep 3600
kubectl wait -n coursework --for=condition=Ready pod/crash --timeout=120s
kubectl patch service web -n coursework -p '{"spec":{"selector":{"app":"wrong"}}}'
kubectl get endpointslices -n coursework -l kubernetes.io/service-name=web
kubectl get pods -n coursework --show-labels
kubectl describe service web -n coursework
kubectl patch service web -n coursework -p '{"spec":{"selector":{"app":"web"}}}'
kubectl exec -n coursework client -- wget -qO- http://web
kubectl run dns-broken -n coursework --image=alpine:3.22 --restart=Never --overrides='{"spec":{"dnsPolicy":"None","dnsConfig":{"nameservers":["192.0.2.1"]}}}' -- sleep 3600
kubectl wait -n coursework --for=condition=Ready pod/dns-broken --timeout=120s
kubectl exec -n coursework dns-broken -- nslookup kubernetes.default || true
kubectl get pod dns-broken -n coursework -o yaml
kubectl delete pod dns-broken -n coursework
kubectl run dns-broken -n coursework --image=alpine:3.22 --restart=Never -- sleep 3600
kubectl wait -n coursework --for=condition=Ready pod/dns-broken --timeout=120s
kubectl exec -n coursework dns-broken -- nslookup kubernetes.default
kubectl get events -n coursework --sort-by=.lastTimestamp
