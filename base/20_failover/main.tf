provider "aws" {
  region              = var.region_failover
  allowed_account_ids = [ var.aws_account_production ]
  version             = "~> 2.0"
}

data "terraform_remote_state" "network_failover" {
  backend = "local"
  config = {
    path = "./../../network/20_failover/terraform.tfstate"
  }
}

module "aws_env_base_fmgmt" {
  source           = "./../../modules/aws-env-base"
  env              = "f${var.env_name_mgmt}"
  vpc_attributes   = data.terraform_remote_state.network_failover.outputs.mgmt_vpc_attributes
}

module "aws_env_base_fprod" {
  source           = "./../../modules/aws-env-base"
  env              = "f${var.env_name_prod}"
  vpc_attributes   = data.terraform_remote_state.network_failover.outputs.prod_vpc_attributes
  create_rds_base  = true
}
