resource "aws_route53_record" "website_custom_domain" {
  zone_id = var.hosted_zone_id
  type = "A"
  name = local.custom_domain
  alias {
    evaluate_target_health = true
    zone_id = aws_lb.ecs_lb.zone_id
    name = aws_lb.ecs_lb.dns_name
  }
}