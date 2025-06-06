# For OIDC provider in GCP
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool-v2"
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-oidc-provider"
  display_name                       = "GitHub Actions OIDC Provider"
  description                        = "GitHub OIDC connect for CI/CD automation pipeline"
  attribute_condition                = <<EOT
    assertion.repository == "${var.github_repo}" &&
    assertion.ref == "refs/heads/main"
EOT
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# GHA OIDC Service Account
resource "google_service_account" "gha_impersonator" {
  account_id   = "gha-impersonator"
  display_name = "GitHub Actions OIDC Impersonator"
}

resource "google_service_account_iam_member" "gha_oidc_impersonate" {
  service_account_id = google_service_account.gha_impersonator.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}

# Deployment Service Account for GHA automation
resource "google_service_account" "terraform_deployer" {
  account_id   = "deployment-service-account"
  display_name = "Deployment Service Account"
}

# Allow impersonation from impersonator
resource "google_service_account_iam_member" "impersonate_deployer" {
  service_account_id = google_service_account.terraform_deployer.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.gha_impersonator.email}"
}

# Assign deployment roles to deployer SA
resource "google_project_iam_member" "terraform_roles" {
  for_each = toset([
    "roles/container.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.securityAdmin"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_deployer.email}"
}

resource "google_storage_bucket_iam_member" "grant_storage_admin" {
  bucket = "terraform-gke-llm-tf-state"
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.gha_impersonator.email}"
}

resource "google_service_account_iam_member" "deployment_sa_impersonate_compute_sa" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/gke-node-sa@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.terraform_deployer.email}"
}

resource "google_project_iam_member" "deployment_sa_impersonate_compute" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.terraform_deployer.email}"
}