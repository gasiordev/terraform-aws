provider "aws" {
  region              = var.region_production
  allowed_account_ids = [ var.aws_account_production ]
  version             = "~> 2.0"
}

module "aws_base_mgmt" {
  source           = "./../../modules/aws-base"
  env              = var.env_name_mgmt
}

module "aws_base_prod" {
  source           = "./../../modules/aws-base"
  env              = var.env_name_prod
}

