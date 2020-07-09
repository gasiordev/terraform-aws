output "env_base_attributes" {
  value = {
    sg = {
      instance = aws_security_group.instance.id,
      lb_internal = aws_security_group.lb_internal.id,
      lb_external = aws_security_group.lb_external.id
    },
    db_subnet_id = {
      private = var.create_rds_base == true && length(aws_db_subnet_group.private) > 0 ? aws_db_subnet_group.private[0].id : "",
      public = var.create_rds_base == true && length(aws_db_subnet_group.private) > 0 ? aws_db_subnet_group.public[0].id : ""
    }
  }
}
