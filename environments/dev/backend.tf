terraform {
  backend "gcs" {
    bucket = "hcl-tf-state-hcl-hackathon-tf-gcp-demo2"
    prefix = "environments/dev"
  }
}
