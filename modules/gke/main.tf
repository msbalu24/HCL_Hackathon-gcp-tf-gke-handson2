resource "google_container_cluster" "primary" {
  name                     = "hcl-${var.environment}-gke"
  project                  = var.project_id
  location                 = var.region
  node_locations           = ["${var.region}-a", "${var.region}-b"]
  network                  = var.vpc_id
  subnetwork               = var.subnet_id
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.master_authorized_cidr
      display_name = "authorized-admin-access"
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
}

resource "google_container_node_pool" "general_pool" {
  name       = "general-pool"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    machine_type    = "e2-medium"
    disk_size_gb    = 30
    disk_type       = "pd-standard"
    service_account = var.gke_node_sa_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      role        = "general"
      environment = var.environment
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}

resource "google_container_node_pool" "critical_pool" {
  name           = "critical-pool"
  project        = var.project_id
  location       = var.region
  node_locations = ["${var.region}-a"]
  cluster        = google_container_cluster.primary.name
  node_count     = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = "e2-small"
    disk_size_gb    = 30
    disk_type       = "pd-standard"
    service_account = var.gke_node_sa_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      workload    = "payment-critical"
      environment = var.environment
    }

    taint {
      key    = "dedicated"
      value  = "payment"
      effect = "NO_SCHEDULE"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = var.app_workload_sa_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[ecommerce/payment-ksa]"

  depends_on = [google_container_cluster.primary]
}
