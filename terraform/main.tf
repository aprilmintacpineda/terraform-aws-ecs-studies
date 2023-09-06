terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.5.6"
}

resource "random_string" "uid" {
  length = 6
  special = false
}

provider "aws" {
  region = var.AWS_REGION

  # default_tags {
  #   tags = {
  #     Project = "${var.stage}-${var.project_name}-${random_string.uid.result}"
  #   }
  # }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "${var.stage}-${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "${var.stage}-${var.project_name}-igw"
  }
}

resource "aws_internet_gateway_attachment" "vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
  internet_gateway_id = aws_internet_gateway.igw.id
}

resource "aws_nat_gateway" "ngw" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.public_subnets_eip.*.allocation_id, count.index)

  tags = {
    Name = "${var.stage}-${var.project_name}-ngw-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_eip" "public_subnets_eip" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.stage}-${var.project_name}-eip"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.availability_zones.names, count.index)
  vpc_id = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.stage}-${var.project_name}-public-subnet-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  count = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.stage}-${var.project_name}-public-rt-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route" "igw_route" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_subnet_rt" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.availability_zones.names, count.index)
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stage}-${var.project_name}-private-subnet-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  count = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.stage}-${var.project_name}-private-rt-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route" "ngw_route" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
  gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnet_rt" {
  count = length(var.private_subnet_cidrs)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
}

resource "aws_security_group" "load_balancer_sec_group" {
  name = "${var.stage}-${var.project_name}-load-balancer-sec-group"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port = 80
    to_port = 80
    protocol = "TCP"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "ecs_service_sec_group" {
  name = "${var.stage}-${var.project_name}-ecs-service-sec-group"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

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

resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name = "/aws/ecs/${var.stage}-${var.project_name}"
  retention_in_days = 30
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
          Resource = "arn:aws:lambda:${var.AWS_REGION}:${local.account_id}:function:${var.stage}-${var.project_name}-*"
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
          Resource = "arn:aws:logs:${var.AWS_REGION}:${local.account_id}:log-group:/aws/ecs/${var.stage}-${var.project_name}:*"
        }
      ]
    })
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.stage}-${var.project_name}-ecs-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_fargate" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.stage}-${var.project_name}-ecs-task-definition"
  container_definitions = jsonencode([
    {
      name = "${var.stage}-${var.project_name}-ecs-container",
      image = "127336369406.dkr.ecr.ap-southeast-1.amazonaws.com/tf-study",
      portMappings = [
        {
          containerPort: 3000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region = var.AWS_REGION,
          awslogs-group = aws_cloudwatch_log_group.ecs_cluster_log_group.name,
          awslogs-stream-prefix = var.stage
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

resource "aws_lb" "ecs_lb" {
  name = "${var.stage}-${var.project_name}-ecs-lb"
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.load_balancer_sec_group.id]
  subnets = aws_subnet.public_subnet.*.id
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_service_load_balancer_target_group.arn
  }
}

resource "aws_lb_target_group" "ecs_service_load_balancer_target_group" {
  name = "${var.stage}-${var.project_name}-ecs-service-lb-tg"
  target_type = "ip"
  vpc_id = aws_vpc.main_vpc.id
  port = 3000
  protocol = "HTTP"
  health_check {
    enabled = true
    interval = 15
    path = "/health"
    protocol = "HTTP"
    timeout = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

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