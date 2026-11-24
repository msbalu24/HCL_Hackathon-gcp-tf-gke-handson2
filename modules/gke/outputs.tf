output "cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "GKE Cluster Region/Location"
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "GKE Control Plane Endpoint"
  value       = google_container_cluster.primary.endpoint
}
