output "source_bucket_name" {
  value = aws_s3_bucket.source.id
}
output "source_bucket_arn" {
  value = aws_s3_bucket.source.arn
}

output "replica_bucket_name" {
  value = var.replica_env != "" ? aws_s3_bucket.replica[0].id : ""
}
output "replica_bucket_arn" {
  value = var.replica_env != "" ? aws_s3_bucket.replica[0].arn : ""
}
