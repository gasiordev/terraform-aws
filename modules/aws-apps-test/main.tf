data "aws_region" "current" {}

module "aws_instance" {
  source = "./../aws-instance"
  env = var.env
  name = "test"
  vpc = var.vpc
  subnet_a = var.private_subnet_a
  subnet_b = var.private_subnet_b
  subnet_c = var.private_subnet_c
  ami = "ami-0ff760d16d9497662"
  instance_type = "t2.micro"
  volume_type = "gp2"
  volume_size = 40
  instance_count = var.instance_count
  key_name = var.ssh_key_name
  tags = {
    vendor = var.vendor
    "${var.vendor}:env" = var.env
    "${var.vendor}:role" = "test"
    "${var.vendor}:tfmodule" = "aws-apps-test"
  }
  security_groups = []
}

# Another way of getting running instance
# Note that it cannot be empty!
#data "aws_instances" "test_instances" {
#  filter {
#    name = "tag:vendor"
#    values = [var.vendor]
#  }
#  filter {
#    name = "tag:${var.vendor}:env"
#    values = [var.env]
#  }
#  filter {
#    name = "tag:${var.vendor}:role"
#    values = ["test"]
#  }
#  instance_state_names = ["running"]
#  depends_on = [module.aws_instance]
#}

module "aws_lb" {
  source = "./../aws-lb"
  env = var.env
  name = "test"
  vpc = var.vpc
  subnet_a = var.public_subnet_a
  subnet_b = var.public_subnet_b
  subnet_c = var.public_subnet_c
  region = data.aws_region.current.name
  availability_zones = [ "${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c" ]
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  ssl_certificate = var.ssl_certificate
  instance_ids = module.aws_instance.instance_ids
  instance_security_group = module.aws_instance.instance_security_group
  internal = false
  listeners = {
    "HTTPS" = 443
    "HTTP" = 80
  }
  target_group_port = 80
  target_group_protocol = "HTTP"
  target_group_healthcheck_path = "/"
  tags = {
    vendor = var.vendor
    "${var.vendor}:env" = var.env
    "${var.vendor}:role" = "test"
    "${var.vendor}:tfmodule" = "aws-apps-test"
  }
  security_groups = []
  route53_zones = var.route53_zones
}

module "aws_db_instance" {
  source = "./../aws-db-instance"
  env = var.env
  name = "test"
  engine = "mysql"
  engine_version = "5.6"
  instance_class = "db.t3.micro"
  storage = "20"
  vpc = var.vpc
  subnet_group = var.private_db_subnet
  security_groups = []
  create_new_security_group = true
  admin_username = var.db_username
  admin_password = var.db_password
  route53_zones = var.route53_zones
  replication_source = var.db_replication_source
}

