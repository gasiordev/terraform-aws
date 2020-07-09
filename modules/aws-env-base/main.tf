resource "aws_security_group" "instance" {
  name = "${var.env}-instance"
  description = "Instance in ${var.env} env"
  vpc_id = var.vpc_attributes.vpc_id

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
  vpc_id = var.vpc_attributes.vpc_id
}
resource "aws_security_group" "lb_external" {
  name = "${var.env}-lb-external"
  description = "External load balancer in ${var.env} env"
  vpc_id = var.vpc_attributes.vpc_id
}

resource "aws_db_subnet_group" "private" {
  name = "${var.env}-private"
  description = "${var.env} DB private subnets group"
  subnet_ids = [
    var.vpc_attributes.subnet_id.private.a,
    var.vpc_attributes.subnet_id.private.b,
    var.vpc_attributes.subnet_id.private.c
  ]

  count = var.create_rds_base == true ? 1 : 0
}

resource "aws_db_subnet_group" "public" {
  name = "${var.env}-public"
  description = "${var.env} DB public subnets group"
  subnet_ids = [
    var.vpc_attributes.subnet_id.public.a,
    var.vpc_attributes.subnet_id.public.b,
    var.vpc_attributes.subnet_id.public.c
  ]

  count = var.create_rds_base == true ? 1 : 0
}
