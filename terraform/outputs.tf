output "ecs-load-balancer-dns-name" {
  value = aws_lb.ecs_lb.dns_name
}

output "health-check-endpoint" {
  value = "http://${aws_lb.ecs_lb.dns_name}/health"
}