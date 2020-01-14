data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region              = var.replica_region
  allowed_account_ids = [ data.aws_caller_identity.current.account_id ]
  version             = "~> 2.0"
  alias               = "replica"
}

resource "aws_iam_role" "replication" {
  name = "${var.env}-${var.replica_env}-${var.name}-s3re"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY

  count = var.replica_env != "" ? 1 : 0
}

resource "aws_iam_policy" "replication" {
  name = "${var.env}-${var.replica_env}-${var.name}-s3re"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.replica[0].arn}/*"
    }
  ]
}
POLICY

  count = var.replica_env != "" ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn

  count = var.replica_env != "" ? 1 : 0
}

resource "aws_s3_bucket" "source" {
  bucket = "${var.vendor}-${var.env}-${var.name}"
  acl = "private"

  versioning {
    enabled = true
  }

  dynamic "replication_configuration" {
    for_each = compact(list(var.replication == true && var.replica_env != "" ? "replicate" : ""))
    content {
      role = aws_iam_role.replication[0].arn
      rules {
        id     = "all"
        status = "Enabled"
  
        destination {
          bucket        = aws_s3_bucket.replica[0].arn
          storage_class = "STANDARD"
        }
      }
    }
  }
}

resource "aws_s3_bucket" "replica" {
  bucket = "${var.vendor}-${var.replica_env}-${var.name}"
  acl = "private"

  versioning {
    enabled = true
  }

  provider = aws.replica

  count = var.replica_env != "" ? 1 : 0
}

