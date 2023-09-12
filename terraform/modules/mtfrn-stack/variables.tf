variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "mongodb_public_key" {
  type = string
}

variable "mongodb_private_key" {
  type = string
}

variable "db_name" {
  type = string
}

variable "website_s3_force_destroy" {
  type = bool
}

variable "cache_policy_id" {
  type = string
  default = "658327ea-f89d-4fab-a63d-7e88639e58f6" // AWS Managed Caching Optimized
}

variable "ecr_repository_force_delete" {
  type = bool
}

variable "vpc_cidr" {
  type = string
}
