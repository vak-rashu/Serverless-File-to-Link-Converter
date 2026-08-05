output "file_upload_bucket_name" {
  value = aws_s3_bucket.s3bucket["file_upload"].id
}

output "file_upload_bucket_arn" {
  value = aws_s3_bucket.s3bucket["file_upload"].arn
}

output "frontend_assest_bucket_name" {
  value = aws_s3_bucket.s3bucket["frontend_assest"].id
}

output "frontend_assest_bucket_arn" {
  value = aws_s3_bucket.s3bucket["frontend_assest"].arn
}
