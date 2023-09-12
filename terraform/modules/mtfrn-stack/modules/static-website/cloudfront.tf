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

  aliases = [var.subdomain != "" ? "${var.subdomain}.${var.hosted_zone_name}" : "${var.hosted_zone_name}"]
  
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
    cache_policy_id = var.cache_policy_id
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
    acm_certificate_arn = aws_acm_certificate.custom_domain_certificate.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }
}
