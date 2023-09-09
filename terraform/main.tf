terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.11"
    }
  }

  required_version = "~> 1.5.6"
}

resource "random_password" "mongodb_atlas_root_user" {
  length = 30
  special = false
  min_lower = 5
  min_upper = 5
  min_numeric = 5
}

provider "aws" {
  region = var.AWS_REGION
}

provider "mongodbatlas" {
  public_key = var.mongodb_atlas_pubkey
  private_key  = var.mongodb_atlas_privkey
}

data "mongodbatlas_roles_org_id" "current" {}

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

resource "aws_appautoscaling_target" "ecs_autoscaling_target" {
  max_capacity = 5
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
  role_arn = "arn:aws:iam::${local.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
}

resource "aws_appautoscaling_policy" "ecs_scale_up_policy" {
  name = "${var.stage}-${var.project_name}-ecs-scale-up-policy"
  policy_type = "StepScaling"
  resource_id = aws_appautoscaling_target.ecs_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_autoscaling_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_autoscaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown = 5
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_scale_down_policy" {
  name = "${var.stage}-${var.project_name}-ecs-scale-down-policy"
  policy_type = "StepScaling"
  resource_id = aws_appautoscaling_target.ecs_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_autoscaling_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_autoscaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown = 5
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_scale_up_cpu_alarm" {
  alarm_name = "${var.stage}-${var.project_name}-ecs-scale-up-cpu-alarm"
  evaluation_periods = 6
  statistic = "Maximum"
  threshold = 61
  period = 10
  alarm_actions = [aws_appautoscaling_policy.ecs_scale_up_policy.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace = "AWS/ECS"
  metric_name = "CPUUtilization"
  dimensions = {
    ServiceName = aws_ecs_service.ecs_service.name
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_scale_down_cpu_alarm" {
  alarm_name = "${var.stage}-${var.project_name}-ecs-scale-down-cpu-alarm"
  evaluation_periods = 6
  statistic = "Maximum"
  threshold = 9
  period = 10
  alarm_actions = [aws_appautoscaling_policy.ecs_scale_down_policy.arn]
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace = "AWS/ECS"
  metric_name = "CPUUtilization"
  dimensions = {
    ServiceName = aws_ecs_service.ecs_service.name
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_scale_up_memory_alarm" {
  alarm_name = "${var.stage}-${var.project_name}-ecs-scale-up-memory-alarm"
  evaluation_periods = 6
  statistic = "Maximum"
  threshold = 81
  period = 10
  alarm_actions = [aws_appautoscaling_policy.ecs_scale_up_policy.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace = "AWS/ECS"
  metric_name = "MemoryUtilization"
  dimensions = {
    ServiceName = aws_ecs_service.ecs_service.name
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_scale_down_memory_alarm" {
  alarm_name = "${var.stage}-${var.project_name}-ecs-scale-down-memory-alarm"
  evaluation_periods = 6
  statistic = "Maximum"
  threshold = 29
  period = 10
  alarm_actions = [aws_appautoscaling_policy.ecs_scale_down_policy.arn]
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace = "AWS/ECS"
  metric_name = "MemoryUtilization"
  dimensions = {
    ServiceName = aws_ecs_service.ecs_service.name
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_ecr_repository" "backend_docker_image" {
  name = "${var.stage}-${var.project_name}"
  force_delete = true
}

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
          "awslogs-region" = var.AWS_REGION,
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
  name = "${var.stage}-${var.project_name}-ecs-lb-tg"
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

resource "aws_s3_bucket" "frontend_s3_bucket" {
  bucket = "${var.stage}-${var.project_name}-frontend-s3-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "frontend_s3_cloudfront_access" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.cf_s3_oai.iam_arn
        }
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.frontend_s3_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "cf_s3_oai" {
  comment = "${var.stage}-${var.project_name}-cf-s3-oac"
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.stage}-${var.project_name}-security-headers"

  security_headers_config {
    // You don't need to specify a value for 'X-Content-Type-Options'.
    // Simply including it in the template sets its value to 'nosniff'.
    content_type_options {
      override = false
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override = false
    }

    strict_transport_security {
      access_control_max_age_sec = 63072000
      override = false
    }

    xss_protection {
      protection = true
      override = false
    }
  }

  remove_headers_config {
    items {
      header = "X-Powered-By"
    }
  }
}

resource "aws_cloudfront_distribution" "frontend_cf" {
  enabled = true
  is_ipv6_enabled = true
  http_version = "http2and3"
  default_root_object = "index.html"
  
  origin {
    domain_name = aws_s3_bucket.frontend_s3_bucket.bucket_regional_domain_name
    origin_id = "${var.stage}-${var.project_name}-s3-bucket-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_s3_oai.cloudfront_access_identity_path
    }
  }
  
  default_cache_behavior {
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" // AWS Managed Caching Optimized
    target_origin_id = "${var.stage}-${var.project_name}-s3-bucket-origin"
    viewer_protocol_policy = "allow-all"
    compress = true
    cached_methods = ["GET", "HEAD", "OPTIONS"]
  }

  custom_error_response {
    error_code = "404"
    response_code = "200"
    response_page_path = "/index.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }
}

resource "null_resource" "frontend_files" {
  triggers = {
    always_run = timestamp()
  }

  // if we have a local .env file, we want to make sure we keep it before creating a new one with different contents
  provisioner "local-exec" {
    command = <<EOF
      [[ ! -f ../apps/web/.env ]] || mv ../apps/web/.env ../apps/web/.env.backup
      touch ../apps/web/.env
      echo "VITE_TRPC_ENDPOINT=http://${aws_lb.ecs_lb.dns_name}/trpc" >> ../apps/web/.env
      yarn --cwd ../apps/web build
      aws s3 sync ../apps/web/dist s3://${aws_s3_bucket.frontend_s3_bucket.id}
      aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.frontend_cf.id} --paths "/*"
      [[ ! -f ../apps/web/.env.backup ]] || mv ../apps/web/.env.backup ../apps/web/.env
    EOF
  }
}

resource "null_resource" "backend_docker_image" {
  triggers = {
    always_run = timestamp()
  }

  // if we have a local .env file, we want to make sure we keep it before creating a new one with different contents
  provisioner "local-exec" {
    command = <<EOF
      [[ ! -f ../apps/server/.env ]] || mv ../apps/server/.env ../apps/server/.env.backup
      touch ../apps/server/.env
      echo "MONGODB_URI=${mongodbatlas_cluster.main_db.srv_address}" >> ../apps/server/.env
      echo "MONGODB_DBNAME=${var.mongodb_dbname}" >> ../apps/server/.env
      echo "MONGODB_USER=root" >> ../apps/server/.env
      echo "MONGODB_PASS=${random_password.mongodb_atlas_root_user.result}" >> ../apps/server/.env
      yarn --cwd ../apps/server build
      docker build -t ${var.stage}-${var.project_name}:latest ../apps/server
      docker tag ${var.stage}-${var.project_name}:latest ${aws_ecr_repository.backend_docker_image.repository_url}:latest
      ecs-cli push ${aws_ecr_repository.backend_docker_image.repository_url}:latest
      aws ecs update-service --cluster ${aws_ecs_cluster.ecs_cluster.name} --service ${aws_ecs_service.ecs_service.name} --force-new-deployment
      [[ ! -f ../apps/server/.env.backup ]] || mv ../apps/server/.env.backup ../apps/server/.env
    EOF
  }
}

resource "mongodbatlas_project" "project" {
  name = "${var.project_name}-${var.stage}"
  org_id = data.mongodbatlas_roles_org_id.current.org_id
}

resource "mongodbatlas_cluster" "main_db" {
  name = "${var.project_name}-${var.stage}"
  project_id = mongodbatlas_project.project.id

  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name = upper(replace(var.AWS_REGION, "-", "_"))
  provider_instance_size_name = "M0"
}

resource "mongodbatlas_database_user" "root_user" {
  username = "root"
  password = random_password.mongodb_atlas_root_user.result
  project_id = mongodbatlas_project.project.id
  auth_database_name = "admin"

  scopes {
    name = mongodbatlas_cluster.main_db.name
    type = "CLUSTER"
  }

  roles {
    role_name = "readWrite"
    database_name = var.mongodb_dbname
  }
}

resource "mongodbatlas_project_ip_access_list" "db_network_access" {
  count = length(var.public_subnet_cidrs)
  project_id = mongodbatlas_project.project.id
  ip_address = element(aws_nat_gateway.ngw.*.public_ip, count.index)
}
