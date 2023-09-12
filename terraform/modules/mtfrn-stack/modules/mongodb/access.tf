resource "mongodbatlas_project_ip_access_list" "db_network_access" {
  count = length(var.public_subnet_cidrs)
  project_id = mongodbatlas_project.project.id
  ip_address = element(var.ngw_public_ips, count.index)
}