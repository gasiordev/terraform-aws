output "mgmt_env" {
  value = "f${data.terraform_remote_state.production.outputs.mgmt_env}"
}

output "prod_env" {
  value = "f${data.terraform_remote_state.production.outputs.prod_env}"
}

output "region" {
  value = data.aws_region.current.name
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
