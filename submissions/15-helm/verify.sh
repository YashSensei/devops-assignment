#!/usr/bin/env bash
set -euxo pipefail
helm create /tmp/kitledger-created-chart
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus-community/prometheus
chart=submissions/15-helm/notes-chart
helm lint "$chart"
helm template notes "$chart"
helm install notes "$chart" -n coursework --wait --timeout=180s
helm list -n coursework
helm status notes -n coursework
helm get all notes -n coursework
helm upgrade notes "$chart" -n coursework -f "$chart/values-prod.yaml" --wait --timeout=180s
kubectl get pods -n coursework -l app=notes
helm upgrade notes "$chart" -n coursework -f "$chart/values-prod.yaml" --set image=nginx:kitledger-intentional-missing-tag
sleep 20
kubectl describe pods -n coursework -l app=notes
helm history notes -n coursework
helm rollback notes 2 -n coursework --wait --timeout=180s
kubectl get pods -n coursework -l app=notes
curl --fail "http://$(minikube -p coursework ip):30090"
helm uninstall notes -n coursework
kubectl get deployment notes -n coursework && exit 1 || true
