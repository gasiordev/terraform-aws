
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "subnet_public_a" {
  value = "${aws_subnet.public_a.id}"
}

output "subnet_public_b" {
  value = "${aws_subnet.public_b.id}"
}

output "subnet_public_c" {
  value = "${aws_subnet.public_c.id}"
}

output "subnet_private_a" {
  value = "${aws_subnet.private_a.id}"
}

output "subnet_private_b" {
  value = "${aws_subnet.private_b.id}"
}

output "subnet_private_c" {
  value = "${aws_subnet.private_c.id}"
}

output "route_table_public" {
  value = "${aws_route_table.public.id}"
}

output "route_table_private_a" {
  value = "${aws_route_table.private_a.id}"
}

output "route_table_private_b" {
  value = "${aws_route_table.private_b.id}"
}

output "route_table_private_c" {
  value = "${aws_route_table.private_c.id}"
}

output "cidr_block" {
  value = "${var.ip_prefix}.0.0/16"
}

