resource "aws_s3_bucket" "frontend_s3_bucket" {
  bucket = "${var.stage}-${var.project_name}-frontend-s3-bucket"
  force_destroy = var.force_destroy
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