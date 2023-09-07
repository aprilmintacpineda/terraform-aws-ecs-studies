output "api-endpoint" {
  value = "http://${aws_lb.ecs_lb.dns_name}"
}

output "api-load-test-endpoint" {
  value = "http://${aws_lb.ecs_lb.dns_name}/load-test"
}

output "api-health-check-endpoint" {
  value = "http://${aws_lb.ecs_lb.dns_name}/health"
}

output "frontend-endpoint" {
  value = "https://${aws_cloudfront_distribution.frontend_cf.domain_name}"
}