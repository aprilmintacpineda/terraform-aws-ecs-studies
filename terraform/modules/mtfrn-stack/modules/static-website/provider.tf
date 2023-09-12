provider "aws" {
  region = var.aws_region
}

provider "aws" {
  # ACM certificate for cloudfront has to be hosted on us-east-1 region
  alias = "acm_certificate"
  region = "us-east-1"
}