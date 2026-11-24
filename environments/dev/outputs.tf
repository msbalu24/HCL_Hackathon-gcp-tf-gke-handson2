output "vpc_name" {
  description = "Provisioned VPC network name"
  value       = module.networking.vpc_name
}

output "subnet_name" {
  description = "Provisioned private subnet name"
  value       = module.networking.subnet_name
}

output "pods_secondary_range" {
  description = "Secondary IP range name for GKE Pods"
  value       = module.networking.pods_range_name
}

output "services_secondary_range" {
  description = "Secondary IP range name for GKE Services"
  value       = module.networking.services_range_name
}

output "gke_cluster_name" {
  description = "Provisioned Private GKE Cluster Name"
  value       = module.gke.cluster_name
}

output "gke_cluster_location" {
  description = "Provisioned GKE Cluster Region"
  value       = module.gke.cluster_location
}

output "app_workload_sa_email" {
  description = "Workload Identity GCP Service Account Email for Payment KSA"
  value       = module.iam.app_workload_sa_email
}

output "payment_secret_id" {
  description = "Google Secret Manager ID for Payment API Key"
  value       = module.storage.payment_secret_id
}

output "artifacts_bucket_name" {
  description = "Secure GCS Artifacts Bucket Name"
  value       = module.storage.artifacts_bucket_name
}
