module "mongodb" {
  source = "./modules/mongodb"
  aws_region = var.aws_region
  db_name = var.db_name
  private_key = var.mongodb_private_key
  public_key = var.mongodb_public_key
  project_name = var.project_name
  stage = var.stage
  public_subnet_cidrs = var.public_subnet_cidrs
  ngw_public_ips = module.ecs.ngw_public_ips
}

module "static_website" {
  source = "./modules/static-website"
  force_destroy = var.website_s3_force_destroy
  aws_region = var.aws_region
  project_name = var.project_name
  stage = var.stage
}

module "ecs" {
  source = "./modules/ecs"
  aws_region = var.aws_region
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
  ecr_repository_force_delete = var.ecr_repository_force_delete
  project_name = var.project_name
  stage = var.stage
  vpc_cidr = var.vpc_cidr
}