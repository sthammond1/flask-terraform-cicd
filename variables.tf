variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "docker_image" {
  description = "Docker image URI built by GitLab CI"
  type        = string
}
