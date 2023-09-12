variable "stage" {
  type = string
}

variable "project_name" {
  type = string
}

variable "ecr_repository_force_delete" {
  type = bool
}

variable "aws_region" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}
