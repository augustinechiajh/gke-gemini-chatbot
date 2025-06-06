output "GCP_WORKLOAD_IDENITTY_PROVIDER" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

output "GCP_IMPERSONATOR_SA" {
  value = google_service_account.gha_impersonator.email
}