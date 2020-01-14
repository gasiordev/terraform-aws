# AWS account details that must come from separate .tfvars file
variable "aws_account_production" {}

variable "aws_account_test" {}
variable "aws_account_test_role_arn" {}

# Vendor is used in names for global resources like S3 buckets
variable "vendor" {
  default = "nicholas"
}

# Environment names - used for Name tag etc.
variable "env_name_mgmt" {
  default = "mgmt"
}
variable "env_name_prod" {
  default = "prod"
}
variable "env_name_stag" {
  default = "stag"
}
variable "env_name_dev" {
  default = "dev"
}

# AWS regions for environments. Note that under "production" there are both
# prod and mgmt and under "failover" there are fprod and fmgmt.
variable "region_production" {
  default = "eu-west-1"
}
variable "region_failover" {
  default = "eu-west-2"
}
variable "region_staging" {
  default = "eu-west-1"
}
variable "region_development" {
  default = "eu-west-1"
}

# IP prefix for CIDR blocks for environments - "10.20" become "10.20.0.0/16" 
# etc.
variable "ip_prefix_mgmt" {
  default = "10.20"
}
variable "ip_prefix_prod" {
  default = "10.30"
}
variable "ip_prefix_stag" {
  default = "10.40"
}
variable "ip_prefix_dev" {
  default = "10.50"
}
variable "ip_prefix_fmgmt" {
  default = "10.120"
}
variable "ip_prefix_fprod" {
  default = "10.130"
}
