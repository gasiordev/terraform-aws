output "mgmt_env" {
  value = "f${data.terraform_remote_state.production.outputs.mgmt_env}"
}

output "prod_env" {
  value = "f${data.terraform_remote_state.production.outputs.prod_env}"
}

output "region" {
  value = data.aws_region.current.name
}

output "mgmt_vpc_id" {
  value = module.aws_vpc_mgmt.vpc_id
}

output "mgmt_subnet_public_a" {
  value = module.aws_vpc_mgmt.subnet_public_a
}

output "mgmt_subnet_public_b" {
  value = module.aws_vpc_mgmt.subnet_public_b
}

output "mgmt_subnet_public_c" {
  value = module.aws_vpc_mgmt.subnet_public_c
}

output "mgmt_subnet_private_a" {
  value = module.aws_vpc_mgmt.subnet_private_a
}

output "mgmt_subnet_private_b" {
  value = module.aws_vpc_mgmt.subnet_private_b
}

output "mgmt_subnet_private_c" {
  value = module.aws_vpc_mgmt.subnet_private_c
}

output "mgmt_route_table_public" {
  value = module.aws_vpc_mgmt.route_table_public
}

output "mgmt_route_table_private_a" {
  value = module.aws_vpc_mgmt.route_table_private_a
}

output "mgmt_route_table_private_b" {
  value = module.aws_vpc_mgmt.route_table_private_b
}

output "mgmt_route_table_private_c" {
  value = module.aws_vpc_mgmt.route_table_private_c
}

output "mgmt_cidr_block" {
  value = module.aws_vpc_mgmt.cidr_block
}


output "prod_vpc_id" {
  value = module.aws_vpc_prod.vpc_id
}

output "prod_subnet_public_a" {
  value = module.aws_vpc_prod.subnet_public_a
}

output "prod_subnet_public_b" {
  value = module.aws_vpc_prod.subnet_public_b
}

output "prod_subnet_public_c" {
  value = module.aws_vpc_prod.subnet_public_c
}

output "prod_subnet_private_a" {
  value = module.aws_vpc_prod.subnet_private_a
}

output "prod_subnet_private_b" {
  value = module.aws_vpc_prod.subnet_private_b
}

output "prod_subnet_private_c" {
  value = module.aws_vpc_prod.subnet_private_c
}

output "prod_route_table_public" {
  value = module.aws_vpc_prod.route_table_public
}

output "prod_route_table_private_a" {
  value = module.aws_vpc_prod.route_table_private_a
}

output "prod_route_table_private_b" {
  value = module.aws_vpc_prod.route_table_private_b
}

output "prod_route_table_private_c" {
  value = module.aws_vpc_prod.route_table_private_c
}

output "prod_cidr_block" {
  value = module.aws_vpc_prod.cidr_block
}

output "prod_mgmt_vpc_peering_connection_id" {
  value = module.aws_vpc_peering_requester_prod_mgmt.vpc_peering_connection_id
}
