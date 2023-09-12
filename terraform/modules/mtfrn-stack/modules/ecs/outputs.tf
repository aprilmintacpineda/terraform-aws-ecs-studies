output "trcp_endpoint" {
  value = "http://${aws_lb.ecs_lb.dns_name}/trpc"
}

output "ecr_repo_url" {
  value = aws_ecr_repository.backend_docker_image.repository_url
}

output "cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "ecs_lb_dns_name" {
  value = aws_lb.ecs_lb.dns_name
}

output "ngw_public_ips" {
  value = aws_nat_gateway.ngw.*.public_ip
}
