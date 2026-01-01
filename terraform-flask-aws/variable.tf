variable "gitlab_token" {
  description = "GitLab token for pulling Docker images"
  type        = string
  sensitive   = true
}
