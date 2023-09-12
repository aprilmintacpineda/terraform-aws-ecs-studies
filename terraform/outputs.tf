output "api-endpoint" {
  value = "http://${module.mtfrn_stack.ecs_lb_dns_name}"
}

output "api-load-test-endpoint" {
  value = "http://${module.mtfrn_stack.ecs_lb_dns_name}/load-test"
}

output "api-health-check-endpoint" {
  value = "http://${module.mtfrn_stack.ecs_lb_dns_name}/health"
}

output "frontend-endpoint" {
  value = "https://${module.mtfrn_stack.website_cf_domain_name}"
}

output "api-docker-image" {
  value = module.mtfrn_stack.ecr_repo_url
}
