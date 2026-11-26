variable "alert_email" {
  type        = string
  default     = "sre-oncall@hcl-ecommerce.local"
  description = "Notification email for SRE alerts"
}

module "monitoring" {
  source      = "../../modules/monitoring"
  project_id  = var.project_id
  environment = var.environment
  alert_email = var.alert_email
}

output "monitoring_notification_channel" {
  value = module.monitoring.notification_channel_id
}
