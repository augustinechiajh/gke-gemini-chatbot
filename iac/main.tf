resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
}

resource "google_container_node_pool" "primary_nodes" {
  depends_on = [google_container_cluster.primary]

  name       = "node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name

  node_config {
    machine_type    = "n2-standard-8"
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  initial_node_count = 1
}