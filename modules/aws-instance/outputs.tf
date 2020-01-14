output "instance_security_group" {
  value = aws_security_group.instance.id
}

output "instance_profile" {
  value = var.instance_profile != "" ? var.instance_profile : aws_iam_instance_profile.instance[0].id
}

output "instance_ids" {
  value = aws_instance.instance.*.id
}

output "instance_private_ips" {
  value = aws_instance.instance.*.private_ip
}
