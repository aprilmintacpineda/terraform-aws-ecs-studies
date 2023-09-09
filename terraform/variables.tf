variable "project_name" {
  type = string
}

variable "AWS_REGION" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "stage" {
  type = string
}

variable "mongodb_atlas_pubkey" {
  type = string
}

variable "mongodb_atlas_privkey" {
  type = string
}

variable "mongodb_dbname" {
  type = string
}
