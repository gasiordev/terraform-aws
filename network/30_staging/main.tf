data "terraform_remote_state" "production" {
  backend = "local"
  config = {
    path = "../10_production/terraform.tfstate"
  }
}

# Staging is clone of production but on different AWS account and without the
# mgmt environment
provider "aws" {
  region                  = var.region_staging
  allowed_account_ids     = [ var.aws_account_test ]
  assume_role {
    role_arn     = var.aws_account_test_role_arn
    session_name = "test"
    external_id  = var.aws_account_test
  }
  version                 = "~> 2.0"
}

provider "aws" {
  alias                   = "production"
  region                  = data.terraform_remote_state.production.outputs.region
  allowed_account_ids     = [ data.terraform_remote_state.production.outputs.account_id ]
  version                 = "~> 2.0"
}

# stag VPC
module "aws_vpc_stag" {
  source    = "./../../modules/aws-vpc"
  env       = var.env_name_stag
  ip_prefix = var.ip_prefix_stag
  vendor    = var.vendor
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# VPC peering between stag and mgmt env of production
module "aws_vpc_peering_requester_stag_mgmt" {
  source                      = "./../../modules/aws-vpc-peering-requester"
  vpc_id                      = module.aws_vpc_stag.vpc_id
  peer_vpc_id                 = data.terraform_remote_state.production.outputs.mgmt_vpc_id
  peer_cidr_block             = data.terraform_remote_state.production.outputs.mgmt_cidr_block
  # We want stag to have access to prod env and that's why prod CIDR block must
  # be routed through stag-mgmt VPC peering
  additional_peer_cidr_blocks = { 
    "prod" = data.terraform_remote_state.production.outputs.prod_cidr_block
  }
  peer_region                 = data.terraform_remote_state.production.outputs.region
  peer_owner_id               = data.terraform_remote_state.production.outputs.account_id
  route_table_public          = module.aws_vpc_stag.route_table_public
  route_table_private_a       = module.aws_vpc_stag.route_table_private_a
  route_table_private_b       = module.aws_vpc_stag.route_table_private_b
  route_table_private_c       = module.aws_vpc_stag.route_table_private_c
  name                        = "${var.env_name_stag}-${data.terraform_remote_state.production.outputs.mgmt_env}"
}

module "aws_vpc_peering_accepter_stag_mgmt" {
  source                     = "./../../modules/aws-vpc-peering-accepter"
  vpc_peering_connection_id  = module.aws_vpc_peering_requester_stag_mgmt.vpc_peering_connection_id
  cidr_block                 = module.aws_vpc_stag.cidr_block
  peer_route_table_public    = data.terraform_remote_state.production.outputs.mgmt_route_table_public
  peer_route_table_private_a = data.terraform_remote_state.production.outputs.mgmt_route_table_private_a
  peer_route_table_private_b = data.terraform_remote_state.production.outputs.mgmt_route_table_private_b
  peer_route_table_private_c = data.terraform_remote_state.production.outputs.mgmt_route_table_private_c
  request_region             = data.aws_region.current.name
  request_owner_id           = data.aws_caller_identity.current.account_id
  name                       = "${var.env_name_stag}-${data.terraform_remote_state.production.outputs.mgmt_env}"
  providers = {
    aws = aws.production
  }
}

# VPC connection options for requester (stag VPC) cannot be added inside the
# accepter module because VPC peering is between VPC's in different accounts
resource "aws_vpc_peering_connection_options" "stag_mgmt_requester" {
  vpc_peering_connection_id = module.aws_vpc_peering_requester_stag_mgmt.vpc_peering_connection_id
  requester {
    allow_remote_vpc_dns_resolution  = true
  }
  count = data.aws_region.current.name != data.terraform_remote_state.production.outputs.region || data.aws_caller_identity.current.account_id != data.terraform_remote_state.production.outputs.account_id ? 1 : 0
  depends_on = [ module.aws_vpc_peering_accepter_stag_mgmt ]
}
