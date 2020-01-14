provider "aws" {
  region              = var.region_production
  allowed_account_ids = [ var.aws_account_production ]
  version             = "~> 2.0"
}

# mgmt env VPC
module "aws_vpc_mgmt" {
  source    = "./../../modules/aws-vpc"
  env       = var.env_name_mgmt
  ip_prefix = var.ip_prefix_mgmt
  vendor    = var.vendor
}

# prod env VPC
module "aws_vpc_prod" {
  source    = "./../../modules/aws-vpc"
  env       = var.env_name_prod
  ip_prefix = var.ip_prefix_prod
  vendor    = var.vendor
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# prod-mgmt VPC peering
module "aws_vpc_peering_requester_prod_mgmt" {
  source                      = "./../../modules/aws-vpc-peering-requester"
  vpc_id                      = module.aws_vpc_prod.vpc_id
  peer_vpc_id                 = module.aws_vpc_mgmt.vpc_id
  peer_cidr_block             = module.aws_vpc_mgmt.cidr_block
  # prod environment should have access to stag and dev environments
  # through prod-mgmt VPC peering, hence their CIDR blocks must be added in
  # the route tables
  additional_peer_cidr_blocks = {
    "stag" = "${var.ip_prefix_stag}.0.0/16",
    "dev"  = "${var.ip_prefix_dev}.0.0/16"
  }
  peer_region                 = data.aws_region.current.name
  peer_owner_id               = data.aws_caller_identity.current.account_id
  route_table_public          = module.aws_vpc_prod.route_table_public
  route_table_private_a       = module.aws_vpc_prod.route_table_private_a
  route_table_private_b       = module.aws_vpc_prod.route_table_private_b
  route_table_private_c       = module.aws_vpc_prod.route_table_private_c
  name                        = "${var.env_name_prod}-${var.env_name_mgmt}"
}

module "aws_vpc_peering_accepter_prod_mgmt" {
  source                     = "./../../modules/aws-vpc-peering-accepter"
  vpc_peering_connection_id  = module.aws_vpc_peering_requester_prod_mgmt.vpc_peering_connection_id
  cidr_block                 = module.aws_vpc_prod.cidr_block
  peer_route_table_public    = module.aws_vpc_mgmt.route_table_public
  peer_route_table_private_a = module.aws_vpc_mgmt.route_table_private_a
  peer_route_table_private_b = module.aws_vpc_mgmt.route_table_private_b
  peer_route_table_private_c = module.aws_vpc_mgmt.route_table_private_c
  request_region             = data.aws_region.current.name
  request_owner_id           = data.aws_caller_identity.current.account_id
  name                       = "${var.env_name_prod}-${var.env_name_mgmt}"
}

