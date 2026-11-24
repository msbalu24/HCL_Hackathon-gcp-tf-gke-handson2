output "gke_node_sa_email" {
  description = "Email of the GKE Node Service Account"
  value       = google_service_account.gke_nodes.email
}

output "app_workload_sa_id" {
  description = "Fully qualified resource ID of the App Workload Service Account"
  value       = google_service_account.app_workload.id
}

output "app_workload_sa_email" {
  description = "Email of the App Workload Service Account"
  value       = google_service_account.app_workload.email
}
