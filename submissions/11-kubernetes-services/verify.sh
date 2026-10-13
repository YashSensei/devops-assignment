#!/usr/bin/env bash
set -euxo pipefail
kubectl apply -n coursework -f submissions/11-kubernetes-services/services.yaml
kubectl get svc,endpointslices -n coursework
kubectl exec -n coursework client -- wget -qO- http://web
kubectl exec -n coursework client -- nslookup web.coursework.svc.cluster.local
kubectl exec -n coursework client -- nslookup headless-web.coursework.svc.cluster.local
kubectl exec -n coursework client -- nslookup external-web.coursework.svc.cluster.local
kubectl exec -n coursework client -- wget -qO- http://external-web
curl --fail "http://$(minikube -p coursework ip):30088"
minikube -p coursework tunnel > /tmp/coursework-tunnel.log 2>&1 &
for i in $(seq 1 30); do
  lb="$(kubectl get svc loadbalancer-web -n coursework -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
  [ -z "$lb" ] || break
  sleep 2
done
test -n "$lb"
curl --fail "http://$lb"
kubectl get svc -n coursework
kubectl get configmap coredns -n kube-system -o yaml
