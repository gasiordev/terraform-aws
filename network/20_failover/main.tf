data "terraform_remote_state" "production" {
  backend = "local"
  config = {
    path = "../10_production/terraform.tfstate"
  }
}

# Failover is a clone of production environments but in a different region
# hence two providers with different region
provider "aws" {
  region              = var.region_failover
  allowed_account_ids = [ data.terraform_remote_state.production.outputs.account_id ]
  version             = "~> 2.0"
}

provider "aws" {
  alias               = "production"
  region              = data.terraform_remote_state.production.outputs.region
  allowed_account_ids = [ data.terraform_remote_state.production.outputs.account_id ]
  version             = "~> 2.0"
}

# Failover environments are named same as production ones but prefixed with "f"
# fmgmt env VPC
module "aws_vpc_mgmt" {
  source    = "./../../modules/aws-vpc"
  env       = "f${data.terraform_remote_state.production.outputs.mgmt_env}"
  ip_prefix = var.ip_prefix_fmgmt
  vendor    = var.vendor
}

# fprod env VPC
module "aws_vpc_prod" {
  source    = "./../../modules/aws-vpc"
  env       = "f${data.terraform_remote_state.production.outputs.prod_env}"
  ip_prefix = var.ip_prefix_fprod
  vendor    = var.vendor
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# fprod-fmgmt VPC peering
module "aws_vpc_peering_requester_prod_mgmt" {
  source                     = "./../../modules/aws-vpc-peering-requester"
  vpc_id                     = module.aws_vpc_prod.vpc_attributes.vpc_id
  peer_vpc_id                = module.aws_vpc_mgmt.vpc_attributes.vpc_id
  peer_cidr_block            = module.aws_vpc_mgmt.vpc_attributes.cidr_block
  peer_region                = data.aws_region.current.name
  peer_owner_id              = data.aws_caller_identity.current.account_id
  route_table_public         = module.aws_vpc_prod.vpc_attributes.route_table_id.public
  route_table_private_a      = module.aws_vpc_prod.vpc_attributes.route_table_id.private.a
  route_table_private_b      = module.aws_vpc_prod.vpc_attributes.route_table_id.private.b
  route_table_private_c      = module.aws_vpc_prod.vpc_attributes.route_table_id.private.c
  name                       = "f${data.terraform_remote_state.production.outputs.prod_env}-f${data.terraform_remote_state.production.outputs.mgmt_env}"
}

module "aws_vpc_peering_accepter_prod_mgmt" {
  source                     = "./../../modules/aws-vpc-peering-accepter"
  vpc_peering_connection_id  = module.aws_vpc_peering_requester_prod_mgmt.vpc_peering_connection_id
  cidr_block                 = module.aws_vpc_prod.vpc_attributes.cidr_block
  peer_route_table_public    = module.aws_vpc_mgmt.vpc_attributes.route_table_id.public
  peer_route_table_private_a = module.aws_vpc_mgmt.vpc_attributes.route_table_id.private.a
  peer_route_table_private_b = module.aws_vpc_mgmt.vpc_attributes.route_table_id.private.b
  peer_route_table_private_c = module.aws_vpc_mgmt.vpc_attributes.route_table_id.private.c
  request_region             = data.aws_region.current.name
  request_owner_id           = data.aws_caller_identity.current.account_id
  name                       = "f${data.terraform_remote_state.production.outputs.prod_env}-f${data.terraform_remote_state.production.outputs.mgmt_env}"
}

# VPC peering between mgmt environments in production and failover (fmgmt-mgmt)
module "aws_vpc_peering_requester_fmgmt_mgmt" {
  source                     = "./../../modules/aws-vpc-peering-requester"
  vpc_id                     = module.aws_vpc_mgmt.vpc_attributes.vpc_id
  peer_vpc_id                = data.terraform_remote_state.production.outputs.mgmt_vpc_attributes.vpc_id
  peer_cidr_block            = data.terraform_remote_state.production.outputs.mgmt_vpc_attributes.cidr_block
  peer_region                = data.terraform_remote_state.production.outputs.region
  peer_owner_id              = data.terraform_remote_state.production.outputs.account_id
  route_table_public         = module.aws_vpc_mgmt.vpc_attributes.route_table_id.public
  route_table_private_a      = module.aws_vpc_mgmt.vpc_attributes.route_table_id.private.a
  route_table_private_b      = module.aws_vpc_mgmt.vpc_attributes.route_table_id.private.b
  route_table_private_c      = module.aws_vpc_mgmt.vpc_attributes.route_table_id.private.c
  name                       = "f${data.terraform_remote_state.production.outputs.mgmt_env}-${data.terraform_remote_state.production.outputs.mgmt_env}"
}

module "aws_vpc_peering_accepter_fmgmt_mgmt" {
  source                     = "./../../modules/aws-vpc-peering-accepter"
  vpc_peering_connection_id  = module.aws_vpc_peering_requester_fmgmt_mgmt.vpc_peering_connection_id
  cidr_block                 = module.aws_vpc_mgmt.vpc_attributes.cidr_block
  peer_route_table_public    = data.terraform_remote_state.production.outputs.mgmt_vpc_attributes.route_table_id.public
  peer_route_table_private_a = data.terraform_remote_state.production.outputs.mgmt_vpc_attributes.route_table_id.private.a
  peer_route_table_private_b = data.terraform_remote_state.production.outputs.mgmt_vpc_attributes.route_table_id.private.b
  peer_route_table_private_c = data.terraform_remote_state.production.outputs.mgmt_vpc_attributes.route_table_id.private.c
  request_region             = data.aws_region.current.name
  request_owner_id           = data.aws_caller_identity.current.account_id
  name                       = "f${data.terraform_remote_state.production.outputs.mgmt_env}-${data.terraform_remote_state.production.outputs.mgmt_env}"
  providers = {
    aws = aws.production
  }
}

# VPC peering is between VPC's that are in different regions and because of
# that connection options for requester (requesting VPC) must be set outside
# of accepter module. Accepter cannot set requester options.
resource "aws_vpc_peering_connection_options" "fmgmt_mgmt_requester" {
  vpc_peering_connection_id = module.aws_vpc_peering_requester_fmgmt_mgmt.vpc_peering_connection_id
  requester {
    allow_remote_vpc_dns_resolution  = true
  }
  count = data.aws_region.current.name != data.terraform_remote_state.production.outputs.region || data.aws_caller_identity.current.account_id != data.terraform_remote_state.production.outputs.account_id ? 1 : 0
  depends_on = [ module.aws_vpc_peering_accepter_fmgmt_mgmt ]
}
