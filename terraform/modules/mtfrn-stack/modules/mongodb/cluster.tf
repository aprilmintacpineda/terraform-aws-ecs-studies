resource "mongodbatlas_cluster" "main_db" {
  name = "${var.project_name}-${var.stage}"
  project_id = mongodbatlas_project.project.id

  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name = upper(replace(var.aws_region, "-", "_"))
  provider_instance_size_name = "M0"
}