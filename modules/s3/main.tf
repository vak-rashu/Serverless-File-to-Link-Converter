#create a bucket resource
resource "aws_s3_bucket" "s3bucket"{
  for_each = [var.file_upload_bucket_name, var.frontend_bucket_name]
  bucket = each.key
}
