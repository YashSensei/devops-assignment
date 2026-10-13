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
kubectl run crash -n coursework --image=alpine:3.22 --restart=Always -- sh -c 'echo deliberate-exit; exit 1'
sleep 20
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
kubectl exec -n coursework dns-broken -- nslookup kubernetes.default.svc.cluster.local
kubectl run pending-demo -n coursework --image=alpine:3.22 --restart=Never --overrides='{"spec":{"nodeSelector":{"kitledger-nonexistent-node":"deliberate"}}}' -- sleep 3600
sleep 10
kubectl describe pod pending-demo -n coursework
kubectl delete pod pending-demo -n coursework
kubectl run pending-demo -n coursework --image=alpine:3.22 --restart=Never -- sleep 3600
kubectl wait -n coursework --for=condition=Ready pod/pending-demo --timeout=120s
kubectl run missing-volume -n coursework --image=alpine:3.22 --restart=Never --overrides='{"spec":{"volumes":[{"name":"settings","configMap":{"name":"lab-missing-settings"}}],"containers":[{"name":"app","image":"alpine:3.22","command":["sleep","3600"],"volumeMounts":[{"name":"settings","mountPath":"/settings"}]}]}}'
sleep 12
kubectl describe pod missing-volume -n coursework
kubectl create configmap lab-missing-settings -n coursework --from-literal=mode=classroom
kubectl wait -n coursework --for=condition=Ready pod/missing-volume --timeout=120s
kubectl exec -n coursework missing-volume -- cat /settings/mode
kubectl run oom-demo -n coursework --image=python:3.13-alpine --restart=Never --overrides='{"spec":{"containers":[{"name":"oom-demo","image":"python:3.13-alpine","command":["python","-c","import time; data=bytearray(100*1024*1024); time.sleep(3600)"],"resources":{"limits":{"memory":"32Mi"}}}]}}'
sleep 30
kubectl describe pod oom-demo -n coursework
kubectl get pod oom-demo -n coursework -o jsonpath='{.status.containerStatuses[0].state.terminated.reason}'
kubectl delete pod oom-demo -n coursework
kubectl run oom-demo -n coursework --image=python:3.13-alpine --restart=Never --overrides='{"spec":{"containers":[{"name":"oom-demo","image":"python:3.13-alpine","command":["python","-c","import time; data=bytearray(100*1024*1024); time.sleep(3600)"],"resources":{"limits":{"memory":"256Mi"}}}]}}'
kubectl wait -n coursework --for=condition=Ready pod/oom-demo --timeout=120s
kubectl exec -n coursework oom-demo -- python -c 'print("Process responds with adequate memory")'
kubectl delete pod oom-demo -n coursework
kubectl get events -n coursework --sort-by=.lastTimestamp
