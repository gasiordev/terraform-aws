output "mgmt_env" {
  value = var.env_name_mgmt
}

output "prod_env" {
  value = var.env_name_prod
}

output "region" {
  value = data.aws_region.current.name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "mgmt_vpc_attributes" {
  value = module.aws_vpc_mgmt.vpc_attributes
}

output "prod_vpc_attributes" {
  value = module.aws_vpc_prod.vpc_attributes
}

output "prod_mgmt_vpc_peering_connection_id" {
  value = module.aws_vpc_peering_requester_prod_mgmt.vpc_peering_connection_id
}
