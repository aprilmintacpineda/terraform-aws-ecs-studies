variable "force_destroy" {
  type = bool
}

variable "cache_policy_id" {
  type = string
  default = "658327ea-f89d-4fab-a63d-7e88639e58f6" // AWS Managed Caching Optimized
}

variable "stage" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}