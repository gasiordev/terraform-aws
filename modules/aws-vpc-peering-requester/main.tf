variable "name" {}
variable "vpc_id" {}
variable "peer_vpc_id" {}
variable "peer_region" {}
variable "route_table_public" {}
variable "route_table_private_a" {}
variable "route_table_private_b" {}
variable "route_table_private_c" {}
variable "peer_cidr_block" {}
variable "additional_peer_cidr_blocks" {
  type = map
  default = {}
}
variable "peer_owner_id" {}

resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.vpc_id
  auto_accept   = false
  peer_region   = var.peer_region
  peer_owner_id = var.peer_owner_id

  tags = {
    Name = var.name
  }
}

resource "aws_route" "public" {
  route_table_id            = var.route_table_public
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
resource "aws_route" "private_a" {
  route_table_id            = var.route_table_private_a
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
resource "aws_route" "private_b" {
  route_table_id            = var.route_table_private_b
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
resource "aws_route" "private_c" {
  route_table_id            = var.route_table_private_c
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "additional_public" {
  for_each = var.additional_peer_cidr_blocks
  route_table_id            = var.route_table_public
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
resource "aws_route" "additional_private_a" {
  for_each = var.additional_peer_cidr_blocks
  route_table_id            = var.route_table_private_a
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
resource "aws_route" "additional_private_b" {
  for_each = var.additional_peer_cidr_blocks
  route_table_id            = var.route_table_private_b
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
resource "aws_route" "additional_private_c" {
  for_each = var.additional_peer_cidr_blocks
  route_table_id            = var.route_table_private_c
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

