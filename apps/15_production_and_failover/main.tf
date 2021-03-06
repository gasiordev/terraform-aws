provider "aws" {
  region              = var.region_production
  allowed_account_ids = [ var.aws_account_production ]
  version             = "~> 2.0"
}

provider "aws" {
  region              = var.region_failover
  allowed_account_ids = [ var.aws_account_production ]
  version             = "~> 2.0"
  alias               = "failover"
}

data "terraform_remote_state" "network_production" {
  backend = "local"
  config = {
    path = "./../../network/10_production/terraform.tfstate"
  }
}
data "terraform_remote_state" "base_production" {
  backend = "local"
  config = {
    path = "./../../base/10_production/terraform.tfstate"
  }
}
data "terraform_remote_state" "network_failover" {
  backend = "local"
  config = {
    path = "./../../network/20_failover/terraform.tfstate"
  }
}
data "terraform_remote_state" "base_failover" {
  backend = "local"
  config = {
    path = "./../../base/20_failover/terraform.tfstate"
  }
}

# Production
module "aws_apps_test_prod" {
  source            = "./../../modules/aws-apps-test"
  vendor            = var.vendor
  env               = "prod"
  vpc_attributes    = data.terraform_remote_state.network_production.outputs.prod_vpc_attributes
  instance_count    = 0
  ssh_key_name      = "nicholas"
  ssl_certificate   = var.production_certificate
  route53_zones     = {
    "awslabs" = var.route53_zone
  }
  private_db_subnet = data.terraform_remote_state.base_production.outputs.prod_env_base_attributes.db_subnet_id.private
  db_username       = "nicholas"
  db_password       = "password123"
}

# Failover
module "aws_apps_test_fprod" {
  source                = "./../../modules/aws-apps-test"
  providers = {
    aws = aws.failover
  }
  vendor                = var.vendor
  env                   = "fprod"
  vpc_attributes        = data.terraform_remote_state.network_failover.outputs.prod_vpc_attributes
  instance_count        = 0
  ssh_key_name          = "nicholas"
  ssl_certificate       = var.failover_certificate
  route53_zones         = {
    "awslabs" = var.route53_zone
  }
  private_db_subnet     = data.terraform_remote_state.base_failover.outputs.fprod_env_base_attributes.db_subnet_id.private
  db_replication_source = var.failover_db_replication == true ? module.aws_apps_test_prod.db_instance_arn : ""
}

# S3 bucket needs cross-region replication so it's coded in a separate module
module "prod_s3_bucket" {
  source = "./../../modules/aws-s3-bucket"
  env = "prod"
  vendor = var.vendor
  name = "test"
  replication = var.failover_s3_bucket_replication
  replica_region = var.region_failover
  replica_env = "fprod"
}
