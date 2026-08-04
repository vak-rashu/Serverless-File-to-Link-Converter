output "file_upload_bucket_name" {
  value = aws_s3_bucket.s3bucket[each.key].id
}

output "file_upload_bucket_arn" {
  value = aws_s3_bucket.s3bucket[each.key].arn
}
