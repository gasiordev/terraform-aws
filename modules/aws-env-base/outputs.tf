output "sg_instance" {
  value = aws_security_group.instance.id
}
output "sg_lb_internal" {
  value = aws_security_group.lb_internal.id
}
output "sg_lb_external" {
  value = aws_security_group.lb_external.id
}

output "db_subnet_private" {
  value = var.create_rds_base == true && length(aws_db_subnet_group.private) > 0 ? aws_db_subnet_group.private[0].id : ""
}
output "db_subnet_public" {
  value = var.create_rds_base == true && length(aws_db_subnet_group.private) > 0 ? aws_db_subnet_group.public[0].id : ""
}
