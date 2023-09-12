output "mongodb_uri" {
  value = mongodbatlas_cluster.main_db.srv_address
}

output "mongodb_root_user_pass" {
  value = random_password.mongodb_atlas_root_user.result
  sensitive = true
}