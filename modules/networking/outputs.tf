output "vpc_id" {
  description = "Created VPC ID"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Created VPC Name"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "Created Subnet ID"
  value       = google_compute_subnetwork.private_subnet.id
}

output "subnet_name" {
  description = "Created Subnet Name"
  value       = google_compute_subnetwork.private_subnet.name
}

output "pods_range_name" {
  description = "Secondary IP range name for GKE Pods"
  value       = google_compute_subnetwork.private_subnet.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Secondary IP range name for GKE Services"
  value       = google_compute_subnetwork.private_subnet.secondary_ip_range[1].range_name
}
