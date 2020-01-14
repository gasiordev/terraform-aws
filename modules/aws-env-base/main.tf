resource "aws_security_group" "instance" {
  name = "${var.env}-instance"
  description = "Instance in ${var.env} env"
  vpc_id = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "lb_internal" {
  name = "${var.env}-lb-internal"
  description = "Internal load balancer in ${var.env} env"
  vpc_id = var.vpc
}
resource "aws_security_group" "lb_external" {
  name = "${var.env}-lb-external"
  description = "External load balancer in ${var.env} env"
  vpc_id = var.vpc
}

resource "aws_db_subnet_group" "private" {
  name = "${var.env}-private"
  description = "${var.env} DB private subnets group"
  subnet_ids = [
    var.private_subnet_a,
    var.private_subnet_b,
    var.private_subnet_c
  ]

  count = var.create_rds_base == true ? 1 : 0
}

resource "aws_db_subnet_group" "public" {
  name = "${var.env}-public"
  description = "${var.env} DB public subnets group"
  subnet_ids = [
    var.public_subnet_a,
    var.public_subnet_b,
    var.public_subnet_c
  ]

  count = var.create_rds_base == true ? 1 : 0
}

