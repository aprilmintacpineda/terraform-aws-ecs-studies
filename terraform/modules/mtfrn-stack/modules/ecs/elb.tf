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
    type = "redirect"
    redirect {
      port = 443
      protocol = "HTTPS"
      host = "#{host}"
      path = "/#{path}"
      query = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.custom_domain_certificate.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_service_load_balancer_target_group.arn
  }
}

resource "aws_lb_listener_rule" "https_listener" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority = 1
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_service_load_balancer_target_group.arn
  }
  condition {
    host_header {
      values = [local.custom_domain]
    }
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