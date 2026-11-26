output "notification_channel_id" {
  value = google_monitoring_notification_channel.sre_email.id
}

output "payment_5xx_metric_name" {
  value = google_logging_metric.payment_5xx_errors.name
}
