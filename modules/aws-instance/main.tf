resource "aws_security_group" "instance" {
  name = "${var.env}-i-${var.name}"
  description = "Instance of ${var.name} in ${var.env} env"
  vpc_id = var.vpc_attributes.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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
  name = "${var.env}-i-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  count = var.instance_profile != "" ? 0 : 1
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.env}-i-${var.name}"
  role = aws_iam_role.instance[0].name

  count = var.instance_profile != "" ? 0 : 1
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
  name = "${var.env}-i-${var.name}"
  role = aws_iam_role.instance[0].id
  policy = data.aws_iam_policy_document.access.json

  count = var.instance_profile != "" ? 0 : 1
}

resource "aws_instance" "instance" {
  instance_type = var.instance_type
  ami = var.ami

  vpc_security_group_ids = concat(var.security_groups, list(aws_security_group.instance.id))

  subnet_id = var.internal ? element(list(var.vpc_attributes.subnet_id.private.a, var.vpc_attributes.subnet_id.private.b, var.vpc_attributes.subnet_id.private.c), (count.index + var.az_offset) % 3) : element(list(var.vpc_attributes.subnet_id.public.a, var.vpc_attributes.subnet_id.public.b, var.vpc_attributes.subnet_id.public.c), (count.index + var.az_offset) % 3)

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  key_name = var.key_name
  associate_public_ip_address = var.internal ? true : false

  iam_instance_profile = var.instance_profile != "" ? var.instance_profile : aws_iam_instance_profile.instance[0].id

  tags = merge(map("${var.vendor}:tfmodule", "aws-instance", "Name", "${var.env}-${var.name}"), var.tags)

  count = var.instance_count
}
