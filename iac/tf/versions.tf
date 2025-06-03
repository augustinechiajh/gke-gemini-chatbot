terraform {
  backend "gcs" {}
  required_version = ">1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "deployment-service-account@${var.project_id}.iam.gserviceaccount.com"
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

data "google_client_config" "default" {}