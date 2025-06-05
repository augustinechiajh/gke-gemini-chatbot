output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint (IP) of the GKE cluster"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Cluster CA Certificate for Kubernetes API"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig file content (access via gcloud token)"
  value       = <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${google_container_cluster.primary.master_auth[0].cluster_ca_certificate}
    server: https://${google_container_cluster.primary.endpoint}
  name: ${google_container_cluster.primary.name}
contexts:
- context:
    cluster: ${google_container_cluster.primary.name}
    user: google
  name: ${google_container_cluster.primary.name}
current-context: ${google_container_cluster.primary.name}
kind: Config
preferences: {}
users:
- name: google
  user:
    auth-provider:
      name: gcp
EOF
  sensitive   = true
}

output "node_instance_group_urls" {
  value = google_container_node_pool.primary_nodes.instance_group_urls
}

output "node_managed_instance_group_urls" {
  value = google_container_node_pool.primary_nodes.managed_instance_group_urls  
}
