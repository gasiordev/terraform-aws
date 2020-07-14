output "instance_attributes" {
  value = {
    role_arn = aws_iam_role.instance.arn
    role_name = aws_iam_role.instance.name
    instance_profile_name = aws_iam_instance_profile.instance.name
  }
}
