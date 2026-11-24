variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for Subnet and Cloud NAT"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR range for GKE nodes"
  type        = string
  default     = "10.10.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for Kubernetes Pods"
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_cidr" {
  description = "Secondary CIDR range for Kubernetes Services"
  type        = string
  default     = "10.30.0.0/20"
}
