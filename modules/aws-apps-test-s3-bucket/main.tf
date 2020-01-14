data "aws_region" "current" {}

module "aws_s3_bucket" {
  source = "./../../modules/aws-s3-bucket"
  vendor = var.vendor
  env = var.env
  name = "test"
  versioning = true
  replication_destination = var.replication_destination
}
