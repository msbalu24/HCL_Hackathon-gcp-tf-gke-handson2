module "networking" {
  source = "../../modules/networking"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

module "iam" {
  source = "../../modules/iam"

  project_id  = var.project_id
  environment = var.environment
}

module "storage" {
  source = "../../modules/storage"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

module "gke" {
  source = "../../modules/gke"

  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  subnet_id           = module.networking.subnet_id
  pods_range_name     = module.networking.pods_range_name
  services_range_name = module.networking.services_range_name
  gke_node_sa_email   = module.iam.gke_node_sa_email
  app_workload_sa_id  = module.iam.app_workload_sa_id
}
