output "artifacts_bucket_name" {
  description = "Name of the secure GCS artifacts bucket"
  value       = google_storage_bucket.artifacts.name
}

output "payment_secret_id" {
  description = "Secret Manager ID for the Payment Service API Key"
  value       = google_secret_manager_secret.payment_api_key.secret_id
}
