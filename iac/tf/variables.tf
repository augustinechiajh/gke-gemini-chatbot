variable "project_id" {
  default = "mystic-castle-460413-g6"
  type    = string
}

variable "region" {
  default = "us-central1"
  type    = string
}

variable "zone" {
  default = "us-central1-a"
  type    = string
}

variable "cluster_name" {
  default = "chatbot-cluster"
  type    = string
}

variable "frontend_image_path" {
  type = string
}

variable "ollama_image_path" {
  type = string
}