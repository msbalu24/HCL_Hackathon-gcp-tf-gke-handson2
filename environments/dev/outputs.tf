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
