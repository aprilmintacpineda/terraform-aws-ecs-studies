resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name = "/aws/ecs/${var.stage}-${var.project_name}"
  retention_in_days = 30
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