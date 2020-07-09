output "mgmt_env_base_attributes" {
  value = module.aws_env_base_mgmt.env_base_attributes
}

output "prod_env_base_attributes" {
  value = module.aws_env_base_prod.env_base_attributes
}
