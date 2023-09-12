locals {
  custom_domain = var.subdomain != "" ? "${var.subdomain}.${var.hosted_zone_name}" : var.hosted_zone_name
}