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
  env               = "prod"
  vpc               = data.terraform_remote_state.network_production.outputs.prod_vpc_id
  private_subnet_a  = data.terraform_remote_state.network_production.outputs.prod_subnet_private_a
  private_subnet_b  = data.terraform_remote_state.network_production.outputs.prod_subnet_private_b
  private_subnet_c  = data.terraform_remote_state.network_production.outputs.prod_subnet_private_c
  public_subnet_a   = data.terraform_remote_state.network_production.outputs.prod_subnet_public_a
  public_subnet_b   = data.terraform_remote_state.network_production.outputs.prod_subnet_public_b
  public_subnet_c   = data.terraform_remote_state.network_production.outputs.prod_subnet_public_c
  instance_count    = 0
  ssh_key_name      = "nicholas"
  ssl_certificate   = var.production_certificate
  route53_zones     = {
    "awslabs" = var.route53_zone
  }
  private_db_subnet = data.terraform_remote_state.base_production.outputs.prod_db_subnet_private
  db_username       = "nicholas"
  db_password       = "password123"
}

# Failover
module "aws_apps_test_fprod" {
  source                = "./../../modules/aws-apps-test"
  providers = {
    aws = aws.failover
  }
  env                   = "fprod"
  vpc                   = data.terraform_remote_state.network_failover.outputs.prod_vpc_id
  private_subnet_a      = data.terraform_remote_state.network_failover.outputs.prod_subnet_private_a
  private_subnet_b      = data.terraform_remote_state.network_failover.outputs.prod_subnet_private_b
  private_subnet_c      = data.terraform_remote_state.network_failover.outputs.prod_subnet_private_c
  public_subnet_a       = data.terraform_remote_state.network_failover.outputs.prod_subnet_public_a
  public_subnet_b       = data.terraform_remote_state.network_failover.outputs.prod_subnet_public_b
  public_subnet_c       = data.terraform_remote_state.network_failover.outputs.prod_subnet_public_c
  instance_count        = 0
  ssh_key_name          = "nicholas"
  ssl_certificate       = var.failover_certificate
  route53_zones         = {
    "awslabs" = var.route53_zone
  }
  private_db_subnet     = data.terraform_remote_state.base_failover.outputs.prod_db_subnet_private
  db_replication_source = var.failover_db_replication == true ? module.aws_apps_test_prod.db_instance_arn : ""
}

# S3 bucket needs cross-region replication so it's coded in a separate module
module "prod_s3_bucket" {
  source = "./../../modules/aws-s3-bucket"
  env = "prod"
  vendor = "nicholas"
  name = "test"
  replication = var.failover_s3_bucket_replication
  replica_region = var.region_failover
  replica_env = "fprod"
}

