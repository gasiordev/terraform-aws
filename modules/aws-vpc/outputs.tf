output "vpc_attributes" {
  value = {
    vpc_id = aws_vpc.main.id,
    subnet_id = {
      private = {
        a = aws_subnet.public_a.id,
        b = aws_subnet.public_b.id,
        c = aws_subnet.public_c.id
      },
      public = {
        a = aws_subnet.private_a.id,
        b = aws_subnet.private_b.id,
        c = aws_subnet.private_c.id
      }
    },
    route_table_id = {
      private = {
        a = aws_route_table.private_a.id,
        b = aws_route_table.private_b.id,
        c = aws_route_table.private_c.id
      },
      public = aws_route_table.public.id
    },
    cidr_block = "${var.ip_prefix}.0.0/16"
  }
}
