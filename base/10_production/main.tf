provider "aws" {
  region              = var.region_production
  allowed_account_ids = [ var.aws_account_production ]
  version             = "~> 2.0"
}

data "terraform_remote_state" "network_production" {
  backend = "local"
  config = {
    path = "./../../network/10_production/terraform.tfstate"
  }
}

module "aws_env_base_mgmt" {
  source           = "./../../modules/aws-env-base"
  env              = var.env_name_mgmt
  vpc_attributes   = data.terraform_remote_state.network_production.outputs.mgmt_vpc_attributes
}

module "aws_env_base_prod" {
  source           = "./../../modules/aws-env-base"
  env              = var.env_name_prod
  vpc_attributes   = data.terraform_remote_state.network_production.outputs.prod_vpc_attributes
  create_rds_base  = true
}
