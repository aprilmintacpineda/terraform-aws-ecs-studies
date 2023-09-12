output "website_s3_id" {
  value = module.static_website.website_s3_id
}

output "website_cf_id" {
  value = module.static_website.website_cf_id
}

output "mongodb_uri" {
  value = module.mongodb.mongodb_uri
}

output "mongodb_root_user_pass" {
  value = module.mongodb.mongodb_root_user_pass
}

output "ecr_repo_url" {
  value = module.ecs.ecr_repo_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "trcp_endpoint" {
  value = module.ecs.trcp_endpoint
}

output "api_endpoint" {
  value = module.ecs.api_endpoint
}

output "ecs_lb_dns_name" {
  value = module.ecs.ecs_lb_dns_name
}

output "website_cf_domain_name" {
  value = module.static_website.website_cf_domain_name
}

output "website_url" {
  value = var.subdomain != "" ? "https://${var.subdomain}.${var.hosted_zone_name}" : "https://${var.hosted_zone_name}"
}
