data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "${var.ip_prefix}.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false

  tags = {
    Name = var.env
    Env  = var.env
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.ip_prefix}.12.0/24"
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = false
}
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.ip_prefix}.14.0/24"
  availability_zone       = "${data.aws_region.current.name}b"
  map_public_ip_on_launch = false
}
resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.ip_prefix}.16.0/24"
  availability_zone       = "${data.aws_region.current.name}c"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.ip_prefix}.22.0/24"
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = false
}
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.ip_prefix}.24.0/24"
  availability_zone       = "${data.aws_region.current.name}b"
  map_public_ip_on_launch = false
}
resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.ip_prefix}.26.0/24"
  availability_zone       = "${data.aws_region.current.name}c"
  map_public_ip_on_launch = false
}

resource "aws_eip" "nat_1" {
  vpc = true
}
resource "aws_eip" "nat_2" {
  vpc = true
}
resource "aws_eip" "nat_3" {
  vpc = true
}

resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_a.id
}
resource "aws_nat_gateway" "b" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_b.id
}
resource "aws_nat_gateway" "c" {
  allocation_id = aws_eip.nat_3.id
  subnet_id     = aws_subnet.public_c.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
}
resource "aws_route" "private_a_nat" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.a.id
  depends_on             = [aws_route_table.private_a]
}
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
}
resource "aws_route" "private_b_nat" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.b.id
  depends_on             = [aws_route_table.private_b]
}
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id
}
resource "aws_route" "private_c_nat" {
  route_table_id         = aws_route_table.private_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.c.id
  depends_on             = [aws_route_table.private_c]
}
resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}

resource "aws_vpc_endpoint" "private_s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id,
    aws_route_table.private_c.id,
  ]
}
