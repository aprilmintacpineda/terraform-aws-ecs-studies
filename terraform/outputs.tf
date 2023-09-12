output "api-endpoint" {
  value = module.mtfrn_stack.api_endpoint
}

output "api-load-test-endpoint" {
  value = "${module.mtfrn_stack.api_endpoint}/load-test"
}

output "api-health-check-endpoint" {
  value = "${module.mtfrn_stack.api_endpoint}/health"
}

output "frontend-endpoint" {
  value = module.mtfrn_stack.website_url
}

output "api-docker-image" {
  value = module.mtfrn_stack.ecr_repo_url
}
