variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "production_name" {
  description = "Name of the cluster"
  type        = string
  default     = "production"
}

variable "staging_name" {
  description = "Name of the cluster"
  type        = string
  default     = "staging"
}

variable "repository_name" {
  type        = string
  default     = "infra-with-flux"
  description = "github repository name"
}
