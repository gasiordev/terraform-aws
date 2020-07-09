resource "aws_security_group" "lb" {
  name = "${var.env}-lb-${var.name}"
  description = "Load balancer of ${var.name} in ${var.env} env"
  vpc_id = var.vpc_attributes.vpc_id
}

resource "aws_security_group_rule" "lb_to_instance" {
  type = "egress"
  from_port = var.target_group_port
  to_port = var.target_group_port
  protocol = "tcp"
  security_group_id = aws_security_group.lb.id
  source_security_group_id = var.instance_security_group
}

resource "aws_security_group_rule" "instance_from_lb" {
  type = "ingress"
  from_port = var.target_group_port
  to_port = var.target_group_port
  protocol = "tcp"
  security_group_id = var.instance_security_group
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_lb" "main" {
  name = "${var.env}-${var.name}"
  internal = var.internal
  load_balancer_type = "application"

  security_groups = compact(concat(list(aws_security_group.lb.id), var.security_groups))

  subnets = var.internal ? [var.vpc_attributes.subnet_id.private.a, var.vpc_attributes.subnet_id.private.b, var.vpc_attributes.subnet_id.private.c] : [var.vpc_attributes.subnet_id.public.a, var.vpc_attributes.subnet_id.public.b, var.vpc_attributes.subnet_id.public.c]

  tags = merge(map("${var.vendor}:tfmodule", "aws-lb", "Name", "${var.env}-${var.name}"), var.tags)
}

resource "aws_lb_target_group" "main" {
  name = "${var.env}-${var.name}"
  port = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id = var.vpc_attributes.vpc_id
  deregistration_delay = 30
  health_check {
    path = var.target_group_healthcheck_path
  }
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id = element(var.instance_ids, count.index)
  port = var.target_group_port
  count = length(var.instance_ids)
}

resource "aws_lb_listener" "main" {
  for_each = var.listeners
  port = each.value
  protocol = each.key

  load_balancer_arn = aws_lb.main.arn
  ssl_policy = each.key == "HTTPS" ? var.ssl_policy : null
  certificate_arn = each.key == "HTTPS" ? var.ssl_certificate : null
  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type = "forward"
  }
}

resource "aws_route53_record" "main" {
  for_each = var.route53_zones
  zone_id = each.value

  name = "${var.env}-${var.name}"
  type = "CNAME"
  ttl = 5
  records = [aws_lb.main.dns_name]
}
