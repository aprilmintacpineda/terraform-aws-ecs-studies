resource "aws_route53_record" "website_custom_domain" {
  zone_id = var.hosted_zone_id
  type = "A"
  name = var.subdomain != "" ? "${var.subdomain}.${var.hosted_zone_name}" : var.hosted_zone_name
  alias {
    evaluate_target_health = true
    zone_id = "Z2FDTNDATAQYW2" # constant for cloudfront
    name = aws_cloudfront_distribution.frontend_cf.domain_name
  }
}