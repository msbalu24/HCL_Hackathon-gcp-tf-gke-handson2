resource "google_service_account" "gke_nodes" {
  account_id   = "hcl-${var.environment}-gke-nodes"
  display_name = "GKE Least-Privilege Node Service Account (${var.environment})"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_service_account" "app_workload" {
  account_id   = "hcl-${var.environment}-app-sa"
  display_name = "E-Commerce Workload Identity Service Account (${var.environment})"
  project      = var.project_id
}

resource "google_project_iam_member" "app_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.app_workload.email}"
}
