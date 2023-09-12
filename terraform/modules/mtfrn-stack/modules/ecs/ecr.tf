resource "aws_ecr_repository" "backend_docker_image" {
  name = "${var.stage}-${var.project_name}"
  force_delete = var.ecr_repository_force_delete
}