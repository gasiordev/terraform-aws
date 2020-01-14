output "instance_role" {
  value = aws_iam_role.instance.name
}
output "instance_profile" {
  value = aws_iam_instance_profile.instance.name
}

