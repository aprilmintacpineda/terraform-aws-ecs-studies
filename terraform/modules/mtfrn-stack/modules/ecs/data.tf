data "aws_availability_zones" "availability_zones" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  availability_zones = data.aws_availability_zones.availability_zones.names
  account_id = data.aws_caller_identity.current.account_id
}