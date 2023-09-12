resource "aws_acm_certificate" "custom_domain_certificate" {
  domain_name = var.subdomain != "" ? "${var.subdomain}.${var.hosted_zone_name}" : var.hosted_zone_name
  validation_method = "DNS"
  provider = aws.acm_certificate
}

resource "aws_route53_record" "custom_domain_certificate" {
  for_each = {
    for option in aws_acm_certificate.custom_domain_certificate.domain_validation_options : option.domain_name => {
      name = option.resource_record_name
      record = option.resource_record_value
      type = option.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "custom_domain_certificate" {
  provider = aws.acm_certificate
  certificate_arn = aws_acm_certificate.custom_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.custom_domain_certificate : record.fqdn]
}