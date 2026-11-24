variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Default GCP Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
