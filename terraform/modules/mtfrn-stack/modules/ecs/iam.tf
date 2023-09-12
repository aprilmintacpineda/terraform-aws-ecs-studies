resource "aws_iam_role" "ecs_task_definition_exec_role" {
  name = "${var.stage}-${var.project_name}-ecs-task-definition-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole"]
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role" "ecs_task_definition_task_role" {
  name = "${var.stage}-${var.project_name}-ecs-task-definition-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole"]
      }
    ]
  })

  inline_policy {
    name = "${var.stage}-${var.project_name}-resource-access-root-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = ["lambda:InvokeFunction"],
          Resource = "arn:aws:lambda:${var.aws_region}:${local.account_id}:function:${var.stage}-${var.project_name}-*"
        },
        {
          Effect = "Allow"
          Action = [
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucketVersions",
            "s3:GetObjectVersion",
            "s3:DeleteObject"
          ]
          Resource = "arn:aws:s3:::${var.stage}-${var.project_name}-*"
        },
        {
          Effect = "Allow"
          Action = ["ses:SendEmail"]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/ecs/${var.stage}-${var.project_name}:*"
        }
      ]
    })
  }
}
