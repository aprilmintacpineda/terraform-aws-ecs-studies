module "mtfrn_stack" {
  source = "./modules/mtfrn-stack"
  aws_region = var.aws_region
  db_name = var.mongodb_dbname
  mongodb_private_key = var.mongodb_atlas_privkey
  mongodb_public_key = var.mongodb_atlas_pubkey
  project_name = var.project_name
  stage = var.stage
  vpc_cidr = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
  ecr_repository_force_delete = true
  website_s3_force_destroy = true
  hosted_zone_id = var.hosted_zone_id
  hosted_zone_name = var.hosted_zone_name
  subdomain = var.stage != "prod" ? var.stage : ""
}

resource "null_resource" "frontend_files" {
  triggers = {
    always_run = timestamp()
  }

  // if we have a local .env file, we want to make sure we keep it before creating a new one with different contents
  provisioner "local-exec" {
    command = <<EOF
      [[ ! -f ../apps/web/.env ]] || mv ../apps/web/.env ../apps/web/.env.backup
      touch ../apps/web/.env
      echo "VITE_TRPC_ENDPOINT=${module.mtfrn_stack.trcp_endpoint}" >> ../apps/web/.env
      yarn --cwd ../apps/web build
      aws s3 sync ../apps/web/dist s3://${module.mtfrn_stack.website_s3_id}
      aws cloudfront create-invalidation --distribution-id ${module.mtfrn_stack.website_cf_id} --paths "/*"
      [[ ! -f ../apps/web/.env.backup ]] || mv ../apps/web/.env.backup ../apps/web/.env
    EOF
  }
}

resource "null_resource" "backend_docker_image" {
  triggers = {
    always_run = timestamp()
  }

  // if we have a local .env file, we want to make sure we keep it before creating a new one with different contents
  provisioner "local-exec" {
    command = <<EOF
      [[ ! -f ../apps/server/.env ]] || mv ../apps/server/.env ../apps/server/.env.backup
      touch ../apps/server/.env
      echo "MONGODB_URI=${module.mtfrn_stack.mongodb_uri}" >> ../apps/server/.env
      echo "MONGODB_DBNAME=${var.mongodb_dbname}" >> ../apps/server/.env
      echo "MONGODB_USER=root" >> ../apps/server/.env
      echo "MONGODB_PASS=${module.mtfrn_stack.mongodb_root_user_pass}" >> ../apps/server/.env
      yarn --cwd ../apps/server build
      docker build -t ${var.stage}-${var.project_name}:latest ../apps/server
      docker tag ${var.stage}-${var.project_name}:latest ${module.mtfrn_stack.ecr_repo_url}:latest
      ecs-cli push ${module.mtfrn_stack.ecr_repo_url}:latest
      aws ecs update-service --cluster ${module.mtfrn_stack.ecs_cluster_name} --service ${module.mtfrn_stack.ecs_service_name} --force-new-deployment
      [[ ! -f ../apps/server/.env.backup ]] || mv ../apps/server/.env.backup ../apps/server/.env
    EOF
  }
}
