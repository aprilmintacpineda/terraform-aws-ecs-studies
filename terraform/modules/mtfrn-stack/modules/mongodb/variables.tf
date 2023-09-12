variable "public_subnet_cidrs" {
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

variable "public_key" {
  type = string
}

variable "private_key" {
  type = string
}

variable "db_name" {
  type = string
}

variable "ngw_public_ips" {
  type = list(string)
}