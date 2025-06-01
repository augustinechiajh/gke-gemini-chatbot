resource "kubernetes_namespace" "chatbot" {
  metadata {
    name = "chatbot-app"
  }

  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}

# Streamlit UI
resource "kubernetes_deployment" "chatbot_app" {
  metadata {
    name      = "chatbot-app"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
    labels = {
      app = "chatbot-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "chatbot-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "chatbot-app"
        }
      }
      spec {
        container {
          name  = "chatbot-ui"
          image = "gcr.io/mystic-castle-460413-g6/streamlit-chatbot:latest"

          port {
            container_port = 8501
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          env {
            name  = "OLLAMA_HOST"
            value = "http://ollama.chatbot-app.svc.cluster.local:11434"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.chatbot]
}

resource "kubernetes_service" "chatbot_service" {
  metadata {
    name      = "chatbot-service"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
  }

  spec {
    selector = {
      app = "chatbot-app"
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 8501
    }
  }

  depends_on = [
    kubernetes_deployment.chatbot_app
  ]
}

# Deployment Ollama
resource "kubernetes_deployment" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
    labels = {
      app = "ollama"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ollama"
      }
    }

    template {
      metadata {
        labels = {
          app = "ollama"
        }
      }
      spec {
        container {
          name  = "ollama"
          image = "gcr.io/mystic-castle-460413-g6/ollama-server:latest"

          port {
            container_port = 11434
          }

          resources {
            limits = {
              cpu    = "6500m"
              memory = "24Gi"
            }
            requests = {
              cpu    = "6000m"
              memory = "16Gi"
            }
          }

          volume_mount {
            name       = "ollama-models"
            mount_path = "/root/.ollama"
          }
        }

        restart_policy = "Always"

        volume {
          name = "ollama-models"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
  }

  spec {
    selector = {
      app = "ollama"
    }
    port {
      port        = 11434
      target_port = 11434
    }
    type = "ClusterIP"
  }
}