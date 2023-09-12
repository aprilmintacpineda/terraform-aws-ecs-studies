resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.stage}-${var.project_name}-ecs-cluster"
}
