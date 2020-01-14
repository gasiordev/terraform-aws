variable "vpc_peering_connection_id" {}
variable "peer_route_table_public" {}
variable "peer_route_table_private_a" {}
variable "peer_route_table_private_b" {}
variable "peer_route_table_private_c" {}
variable "cidr_block" {}
variable "name" {}
variable "request_region" {}
variable "request_owner_id" {}

resource "aws_vpc_peering_connection_accepter" "main" {
  vpc_peering_connection_id = var.vpc_peering_connection_id
  auto_accept               = true
  tags = {
    Name = var.name
  }
} 

resource "aws_vpc_peering_connection_options" "accepter" {
  vpc_peering_connection_id = var.vpc_peering_connection_id
  accepter {
    allow_remote_vpc_dns_resolution  = true
  }
  depends_on = [ aws_vpc_peering_connection_accepter.main ]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection_options" "requester" {
  vpc_peering_connection_id = var.vpc_peering_connection_id
  requester {
    allow_remote_vpc_dns_resolution  = true
  }
  count = data.aws_region.current.name == var.request_region && data.aws_caller_identity.current.account_id == var.request_owner_id ? 1 : 0
  depends_on = [ aws_vpc_peering_connection_accepter.main ]
}

resource "aws_route" "public" {
  route_table_id            = var.peer_route_table_public
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = var.vpc_peering_connection_id
}
resource "aws_route" "private_a" {
  route_table_id            = var.peer_route_table_private_a
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = var.vpc_peering_connection_id
}
resource "aws_route" "private_b" {
  route_table_id            = var.peer_route_table_private_b
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = var.vpc_peering_connection_id
}
resource "aws_route" "private_c" {
  route_table_id            = var.peer_route_table_private_c
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = var.vpc_peering_connection_id
}

