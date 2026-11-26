variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "alert_email" {
  type        = string
  description = "SRE On-Call email address for Cloud Monitoring alerts"
}
