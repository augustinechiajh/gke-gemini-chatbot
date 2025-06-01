output "github_provider" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

output "terraform_deployer" {
  value = google_service_account.terraform_deployer.email
}