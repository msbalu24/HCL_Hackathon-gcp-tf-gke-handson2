resource "google_storage_bucket" "artifacts" {
  name                        = "hcl-${var.environment}-artifacts-${var.project_id}"
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true

  versioning {
    enabled = true
  }
}

resource "google_secret_manager_secret" "payment_api_key" {
  secret_id = "hcl-${var.environment}-payment-api-key"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "payment_api_key_v1" {
  secret      = google_secret_manager_secret.payment_api_key.id
  secret_data = "sk_live_hcl_ecommerce_payment_gateway_2026"
}
