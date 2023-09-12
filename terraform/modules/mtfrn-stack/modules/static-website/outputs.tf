output "website_s3_id" {
  value = aws_s3_bucket.frontend_s3_bucket.id
}

output "website_cf_id" {
  value = aws_cloudfront_distribution.frontend_cf.id
}

output "website_cf_domain_name" {
  value = aws_cloudfront_distribution.frontend_cf.domain_name
}
