#!/usr/bin/env bash
set -euxo pipefail
kubectl apply -n coursework -f submissions/13-storage-hpa-probes/app.yaml
kubectl rollout status -n coursework deployment/storage-web --timeout=180s
pod="$(kubectl get pod -n coursework -l app=storage-web -o jsonpath='{.items[0].metadata.name}')"
kubectl exec -n coursework "$pod" -- sh -c 'echo "Yash Agrawal 24bcs10164" > /data/student.txt'
kubectl delete pod -n coursework "$pod"
kubectl rollout status -n coursework deployment/storage-web --timeout=180s
kubectl exec -n coursework deployment/storage-web -- cat /data/student.txt
kubectl run load -n coursework --image=alpine:3.22 --restart=Never -- sh -c 'for i in $(seq 1 12); do (while true; do wget -qO- http://storage-web >/dev/null; done) & done; wait'
scaled=false
for i in $(seq 1 36); do
  kubectl get hpa -n coursework
  kubectl top pods -n coursework || true
  count="$(kubectl get hpa storage-web -n coursework -o jsonpath='{.status.currentReplicas}')"
  if [ "${count:-0}" -gt 2 ]; then scaled=true; break; fi
  sleep 10
done
kubectl delete pod load -n coursework
test "$scaled" = true
kubectl patch deployment storage-web -n coursework --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/not-ready"}]'
sleep 30
kubectl get pods,endpointslices -n coursework
kubectl describe deployment storage-web -n coursework
kubectl patch deployment storage-web -n coursework --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]'
kubectl rollout status deployment/storage-web -n coursework --timeout=180s
kubectl patch deployment storage-web -n coursework --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/dead"}]'
sleep 30
kubectl get pods -n coursework
kubectl get events -n coursework --sort-by=.lastTimestamp
kubectl patch deployment storage-web -n coursework --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/"}]'
kubectl rollout status deployment/storage-web -n coursework --timeout=180s
