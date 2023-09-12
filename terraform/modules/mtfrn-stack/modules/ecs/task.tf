resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.stage}-${var.project_name}-ecs-task-definition"
  container_definitions = jsonencode([
    {
      name = "${var.stage}-${var.project_name}-ecs-container",
      image = aws_ecr_repository.backend_docker_image.repository_url,
      portMappings = [
        {
          containerPort: 3000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-region" = var.aws_region,
          "awslogs-group" = aws_cloudwatch_log_group.ecs_cluster_log_group.name,
          "awslogs-stream-prefix" = var.stage
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_definition_exec_role.arn
  task_role_arn = aws_iam_role.ecs_task_definition_task_role.arn
}