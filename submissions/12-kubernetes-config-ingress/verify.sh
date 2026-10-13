#!/usr/bin/env bash
set -euo pipefail
secret="$(openssl rand -hex 16)"
if [ "${GITHUB_ACTIONS:-}" = true ]; then echo "::add-mask::$secret"; fi
kubectl create secret generic coursework-secret -n coursework --from-literal=password="$secret"
set -x
kubectl apply -n coursework -f submissions/12-kubernetes-config-ingress/config.yaml
kubectl wait -n coursework --for=condition=Ready pod/config-reader --timeout=120s
kubectl exec -n coursework config-reader -- printenv ENVIRONMENT
kubectl exec -n coursework config-reader -- sh -c 'test -n "$DEMO_SECRET" && echo "Secret is present; value withheld"'
kubectl describe secret coursework-secret -n coursework
kubectl patch configmap coursework-config -n coursework -p '{"data":{"ENVIRONMENT":"staging"}}'
test "$(kubectl exec -n coursework config-reader -- printenv ENVIRONMENT)" = development
kubectl delete pod config-reader -n coursework
kubectl apply -n coursework -f submissions/12-kubernetes-config-ingress/config.yaml
# Applying the manifest resets ConfigMap; patch again before restarting the consumer.
kubectl patch configmap coursework-config -n coursework -p '{"data":{"ENVIRONMENT":"staging"}}'
kubectl delete pod config-reader -n coursework
kubectl apply -n coursework -f <(sed -n '/kind: Pod/,$p' submissions/12-kubernetes-config-ingress/config.yaml | sed '1i apiVersion: v1') || true
# Newline demonstration uses a public dummy string, not the runtime secret.
printf 'demo-value\n' | base64
printf 'demo-value' | base64
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
curl --fail --retry 10 --retry-all-errors -H 'Host: coursework.local' "http://$(minikube -p coursework ip)/"
