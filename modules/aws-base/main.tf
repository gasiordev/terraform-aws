data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name = "${var.env}-instance"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.env}-instance"
  role = aws_iam_role.instance.name
}

data "aws_iam_policy_document" "access" {
  statement {
    actions = ["ec2:Describe*"]
    resources = ["*"]
    effect = "Allow"
  }
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "access" {
  name = "${var.env}-instance"
  role = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.access.json
}

