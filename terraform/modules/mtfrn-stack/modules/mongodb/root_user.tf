resource "random_password" "mongodb_atlas_root_user" {
  length = 30
  special = false
  min_lower = 5
  min_upper = 5
  min_numeric = 5
}

resource "mongodbatlas_database_user" "root_user" {
  username = "root"
  password = random_password.mongodb_atlas_root_user.result
  project_id = mongodbatlas_project.project.id
  auth_database_name = "admin"

  scopes {
    name = mongodbatlas_cluster.main_db.name
    type = "CLUSTER"
  }

  roles {
    role_name = "readWrite"
    database_name = var.db_name
  }
}