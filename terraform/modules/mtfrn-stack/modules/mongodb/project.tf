resource "mongodbatlas_project" "project" {
  name = "${var.project_name}-${var.stage}"
  org_id = data.mongodbatlas_roles_org_id.current.org_id
}