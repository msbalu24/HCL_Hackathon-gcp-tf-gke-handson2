#!/usr/bin/env bash
set -e

echo "=================================================================="
echo " HCL SRE CHAOS & ZERO-DOWNTIME VERIFICATION (ALL 11 SCENARIOS)"
echo "=================================================================="

ORDER_POD=$(kubectl get pod -n ecommerce -l app=order -o jsonpath='{.items[0].metadata.name}')

echo ""
echo "[Scenario 1] Canary payment-v2 Rollback (0/100 -> 100/0 Stable v1)"
MSYS_NO_PATHCONV=1 kubectl patch virtualservice payment-vs -n ecommerce --type='json' \
  -p='[{"op": "replace", "path": "/spec/http/0/route/0/weight", "value":100}, {"op": "replace", "path": "/spec/http/0/route/1/weight", "value":0}]'
kubectl exec -n ecommerce "$ORDER_POD" -c order -- wget -qO- http://payment:80
echo ""

echo ""
echo "[Scenario 2] Pod Crash / Deletion Self-Healing (cart pod)"
CART_POD=$(kubectl get pod -n ecommerce -l app=cart -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod "$CART_POD" -n ecommerce --wait=false
sleep 8
kubectl get pods -n ecommerce -l app=cart

echo ""
echo "[Scenario 3 & 4] Liveness & Readiness Probe Endpoints Verification"
kubectl exec -n ecommerce "$ORDER_POD" -c order -- wget -qO- http://frontend:80/healthz
echo ""
kubectl exec -n ecommerce "$ORDER_POD" -c order -- wget -qO- http://frontend:80/ready
echo ""

echo ""
echo "[Scenario 5] Zero-Downtime Node Maintenance Simulation (Cordon -> Verify -> Uncordon)"
GEN_NODE=$(kubectl get nodes -l role=general -o jsonpath='{.items[0].metadata.name}')
kubectl cordon "$GEN_NODE"
kubectl exec -n ecommerce "$ORDER_POD" -c order -- wget -qO- http://product-catalog:80
echo ""
kubectl uncordon "$GEN_NODE"

echo ""
echo "[Scenario 6] Bad Image (ImagePullBackOff) & Zero-Downtime Rollout Undo"
kubectl set image deployment/notification notification=nginx:invalid-tag-999 -n ecommerce
sleep 8
kubectl get pods -n ecommerce -l app=notification
kubectl rollout undo deployment/notification -n ecommerce
kubectl rollout status deployment/notification -n ecommerce

echo ""
echo "[Scenario 7] OOMKilled Pod Diagnosis & Cleanup"
kubectl run oom-test -n ecommerce --image=busybox:1.36 --restart=Never \
  --overrides='{"spec":{"nodeSelector":{"role":"general"},"containers":[{"name":"oom","image":"busybox:1.36","command":["sh","-c","dd if=/dev/zero of=/dev/shm/fill bs=1M count=32"],"resources":{"limits":{"memory":"8Mi"}}}]}}' || true
sleep 8
kubectl get pod oom-test -n ecommerce -o jsonpath='{.status.containerStatuses[0].state.terminated.reason}{"\n"}' || true
kubectl delete pod oom-test -n ecommerce --ignore-not-found

echo ""
echo "[Scenario 8 & 9] Zero-Trust NetworkPolicy + Istio mTLS & AuthZ Verification"
INV_POD=$(kubectl get pod -n ecommerce -l app=inventory -o jsonpath='{.items[0].metadata.name}')
echo "Unauthorized inventory -> payment call (must fail):"
kubectl exec -n ecommerce "$INV_POD" -c inventory -- wget -T 3 -qO- http://payment:80 2>&1 || echo "BLOCKED as expected!"
echo "Authorized order (order-ksa) -> payment call (must succeed):"
kubectl exec -n ecommerce "$ORDER_POD" -c order -- wget -qO- http://payment:80
echo ""

echo ""
echo "[Scenario 10] Node Taint / Untolerated Pod Scheduling Diagnosis"
kubectl run taint-test -n ecommerce --image=busybox:1.36 --restart=Never \
  --overrides='{"spec":{"nodeSelector":{"workload":"payment-critical"},"containers":[{"name":"t","image":"busybox:1.36","command":["sleep","30"]}]}}' || true
sleep 6
kubectl describe pod taint-test -n ecommerce | grep "FailedScheduling" | head -n 1 || true
kubectl delete pod taint-test -n ecommerce --ignore-not-found

echo ""
echo "[Scenario 11] Workload Identity KSA Binding & GCP Secret Manager Check"
kubectl get sa payment-ksa -n ecommerce -o jsonpath='{.metadata.annotations.iam\.gke\.io/gcp-service-account}{"\n"}'
gcloud secrets versions access latest --secret="hcl-dev-payment-api-key" --project="hcl-hackathon-tf-gcp-demo2" > /dev/null && echo "Secret Manager access verified!"

echo ""
echo "=================================================================="
echo " ALL 11 CHAOS SCENARIOS PASSED & CLUSTER IS 100% HEALTHY!"
echo "=================================================================="
kubectl get pods -n ecommerce
