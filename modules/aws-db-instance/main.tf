resource "aws_security_group" "db" {
  name = "${var.env}-rds-${var.name}"
  description = "RDS of ${var.name} in ${var.env} env"
  vpc_id = var.vpc_attributes.vpc_id

  count = var.create_new_security_group == true || length(var.security_groups) == 0 ? 1 : 0
}

resource "aws_db_instance" "main" {
  apply_immediately = true
  deletion_protection = false
  identifier = "${var.env}-${var.name}"
  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.storage
  storage_type = "gp2"
  multi_az = false
  db_subnet_group_name = var.subnet_group
  publicly_accessible = false
  vpc_security_group_ids = (var.create_new_security_group == true) || (length(var.security_groups) == 0) ? concat(var.security_groups, list(aws_security_group.db[0].id)) : var.security_groups

  backup_retention_period = 1

  replicate_source_db = var.replication_source

  username = var.replication_source != "" ? null : var.admin_username
  password = var.replication_source != "" ? null : var.admin_password

  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true

  skip_final_snapshot = true
  final_snapshot_identifier = "${var.env}-${var.name}-final-snapshot"
  tags = merge(map("${var.vendor}:tfmodule", "aws-instance", "Name", "${var.env}-${var.name}"), var.tags)
}

resource "aws_route53_record" "main" {
  for_each = var.route53_zones
  zone_id = each.value

  name = "rds-${var.env}-${var.name}"
  type = "CNAME"
  ttl = 5
  records = [aws_db_instance.main.address]
}
