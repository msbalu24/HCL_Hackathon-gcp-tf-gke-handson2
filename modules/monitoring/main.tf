resource "google_monitoring_notification_channel" "sre_email" {
  project      = var.project_id
  display_name = "HCL SRE On-Call Email (${var.environment})"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

resource "google_logging_metric" "payment_5xx_errors" {
  project     = var.project_id
  name        = "hcl-${var.environment}-payment-5xx-count"
  description = "Counts HTTP 5xx responses from payment service containers"
  filter      = "resource.type=\"k8s_container\" AND resource.labels.namespace_name=\"ecommerce\" AND resource.labels.container_name=\"payment\" AND (textPayload:\" 500 \" OR textPayload:\" 502 \" OR textPayload:\" 503 \")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "high_node_cpu" {
  project      = var.project_id
  display_name = "[HCL-${upper(var.environment)}] GKE Node High CPU (>80%)"
  combiner     = "OR"

  conditions {
    display_name = "GCE Instance CPU utilization > 80%"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.sre_email.id]
}

resource "google_monitoring_alert_policy" "pod_restart_alert" {
  project      = var.project_id
  display_name = "[HCL-${upper(var.environment)}] E-Commerce Container Restart Spike"
  combiner     = "OR"

  conditions {
    display_name = "Container restart delta > 2 in 60s"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/container/restart_count\" AND resource.type=\"k8s_container\" AND resource.labels.namespace_name=\"ecommerce\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 2

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.sre_email.id]
}

resource "google_monitoring_alert_policy" "ecommerce_error_log_alert" {
  project      = var.project_id
  display_name = "[HCL-${upper(var.environment)}] E-Commerce Container Error Logs"
  combiner     = "OR"

  conditions {
    display_name = "Container log severity >= ERROR in ecommerce namespace"
    condition_matched_log {
      filter = "resource.type=\"k8s_container\" AND resource.labels.namespace_name=\"ecommerce\" AND severity>=ERROR"
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.sre_email.id]
}
