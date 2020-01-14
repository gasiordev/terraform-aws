output "lb_arn" {
  value = aws_lb.main.arn
}
output "lb_security_group" {
  value = aws_security_group.lb.id
}
output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

