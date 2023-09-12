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