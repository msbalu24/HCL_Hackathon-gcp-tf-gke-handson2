# Enterprise GCP IaC, DevSecOps & Production GKE + Istio Service Mesh

End-to-end, 100% hands-on unified implementation combining **Use Case 1 (Enterprise GCP IaC & DevSecOps CI/CD)** and **Use Case 2 (Production-Ready GKE Microservices & Istio Service Mesh)**.

## Architecture Overview

1. **GCP Foundation & Remote State (`modules/networking`, `environments/dev`):**
   - Custom VPC (`hcl-dev-vpc`) with secondary Pod (`10.20.0.0/16`) and Service (`10.30.0.0/20`) IP ranges, Cloud Router, Cloud NAT, and GCS Remote State Backend with native state locking.
2. **Least-Privilege IAM & Secret Management (`modules/iam`, `modules/storage`):**
   - Dedicated GKE Node Service Account (`hcl-dev-gke-nodes`), Workload Identity Application Service Account (`hcl-dev-app-sa`), and Google Secret Manager (`hcl-dev-payment-api-key`).
3. **Private Regional GKE Cluster (`modules/gke`):**
   - Regional Private GKE cluster (`hcl-dev-gke`) with Calico NetworkPolicy enforcement, Shielded VMs, Workload Identity, `general-pool` (`e2-standard-4`), and tainted `critical-pool` (`e2-standard-2`, `dedicated=payment:NoSchedule`).
4. **7 E-Commerce Microservices & Autoscaling (`k8s/base`, `k8s/microservices`):**
   - `frontend`, `product-catalog`, `cart`, `order`, `payment` (`v1`/`v2`), `inventory`, and `notification` with 3-layer health probes (`startupProbe`, `readinessProbe`, `livenessProbe`), `PodDisruptionBudgets`, `HorizontalPodAutoscalers`, Zero-Trust L3/L4 `NetworkPolicies`, and GKE NEG-backed External HTTPS Ingress.
5. **Istio Service Mesh & Progressive Canary (`k8s/istio`):**
   - Envoy sidecar injection (`2/2`), `STRICT` mTLS (`PeerAuthentication`), SPIFFE identity `AuthorizationPolicy` (`order-ksa` -> `payment`), and progressive `payment` `v1`/`v2` Canary traffic shifting (`90/10` -> `75/25` -> `50/50` -> `0/100`).
6. **Observability, Chaos Engineering & DevSecOps CI/CD (`modules/monitoring`, `scripts/`, `policy/`, `.github/workflows/`):**
   - Cloud Monitoring Alert Policies & Log-Based Metrics, automated 11-scenario SRE Chaos runbook (`scripts/chaos-11-scenarios.sh`), OPA Rego v1 policy gates, Checkov security scanning, and GitHub Actions CI/CD.

## Cost-Saving Cleanup (After Evaluation)

```bash
kubectl delete -f k8s/istio/ --ignore-not-found
kubectl delete -f k8s/microservices/ --ignore-not-found
kubectl delete -f k8s/base/ --ignore-not-found
terraform -chdir=environments/dev destroy -auto-approve
```
