resource "aws_ecs_service" "ecs_service" {
  name = "${var.stage}-${var.project_name}-ecs-service"
  launch_type = "FARGATE"
  desired_count = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn

  network_configuration {
    security_groups = [aws_security_group.ecs_service_sec_group.id]
    subnets = aws_subnet.private_subnet.*.id
  }

  load_balancer {
    container_name = "${var.stage}-${var.project_name}-ecs-container"
    container_port = 3000
    target_group_arn = aws_lb_target_group.ecs_service_load_balancer_target_group.arn
  }
}