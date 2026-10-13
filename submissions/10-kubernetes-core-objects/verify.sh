#!/usr/bin/env bash
set -euxo pipefail
kubectl apply -n coursework -f submissions/10-kubernetes-core-objects/app.yaml
kubectl rollout status -n coursework deployment/web --timeout=180s
old="$(kubectl get pod -n coursework -l app=web -o jsonpath='{.items[0].metadata.name}')"
kubectl delete pod -n coursework "$old"
kubectl rollout status -n coursework deployment/web --timeout=180s
kubectl get rs,pods -n coursework -o wide
kubectl scale deployment/web -n coursework --replicas=3
kubectl rollout status -n coursework deployment/web --timeout=180s
kubectl set image deployment/web -n coursework web=nginx:alpine
kubectl rollout status -n coursework deployment/web --timeout=180s
kubectl rollout history deployment/web -n coursework
kubectl rollout undo deployment/web -n coursework
kubectl rollout status -n coursework deployment/web --timeout=180s
kubectl create deployment blue -n coursework --image=hashicorp/http-echo -- /http-echo -text=blue
kubectl create deployment green -n coursework --image=hashicorp/http-echo -- /http-echo -text=green
kubectl expose deployment blue -n coursework --name=colour --port=80 --target-port=5678
kubectl rollout status deployment/blue -n coursework --timeout=180s
kubectl rollout status deployment/green -n coursework --timeout=180s
kubectl run client -n coursework --image=alpine:3.22 --restart=Never --command -- sleep 3600
kubectl wait -n coursework --for=condition=Ready pod/client --timeout=120s
kubectl exec -n coursework client -- wget -qO- http://colour
kubectl patch service colour -n coursework -p '{"spec":{"selector":{"app":"green"}}}'
kubectl exec -n coursework client -- wget -qO- http://colour
kubectl label pods -n coursework -l app=blue track=canary-demo
kubectl label pods -n coursework -l app=green track=canary-demo
kubectl patch service colour -n coursework -p '{"spec":{"selector":{"app":null,"track":"canary-demo"}}}'
for i in $(seq 1 20); do kubectl exec -n coursework client -- wget -qO- http://colour; done
# Equal replica count is a probability model, not a promised request split.
kubectl patch deployment web -n coursework --type=merge -p '{"spec":{"strategy":{"type":"Recreate","rollingUpdate":null}}}'
kubectl get pods -n coursework -l app=web --watch > /tmp/recreate-observed.log &
watcher=$!
kubectl set image deployment/web -n coursework web=nginx:alpine
kubectl rollout status deployment/web -n coursework --timeout=180s
kill "$watcher" || true
cat /tmp/recreate-observed.log
kubectl apply -n coursework -f submissions/10-kubernetes-core-objects/pod-lifecycle
sleep 20
kubectl get pods -n coursework -o wide
kubectl describe pods -n coursework -l exercise=lifecycle
