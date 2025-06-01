variable "project_id" {
  default = "mystic-castle-460413-g6"
}

variable "region" {
  default = "us-central1"
}

variable "github_repo" {
  description = "name of GitHub Repo"
  type = string
}

variable "github_owner_id" {
  description = "owner ID of GitHub Repo"
  type = string
}