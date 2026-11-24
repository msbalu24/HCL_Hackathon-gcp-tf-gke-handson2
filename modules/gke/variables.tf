variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for Regional GKE Cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC Network ID from networking module"
  type        = string
}

variable "subnet_id" {
  description = "Private Subnet ID from networking module"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary IP range name for Pods"
  type        = string
}

variable "services_range_name" {
  description = "Secondary IP range name for Services"
  type        = string
}

variable "gke_node_sa_email" {
  description = "Least-privilege Service Account email for GKE nodes"
  type        = string
}

variable "app_workload_sa_id" {
  description = "Resource ID of App Service Account for Workload Identity"
  type        = string
}

variable "master_authorized_cidr" {
  description = "CIDR block allowed to reach GKE Control Plane"
  type        = string
  default     = "0.0.0.0/0"
}
