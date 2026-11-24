module "networking" {
  source = "../../modules/networking"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}
