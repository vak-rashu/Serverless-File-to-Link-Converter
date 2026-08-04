#create a bucket resource
resource "aws_s3_bucket" "s3bucket"{
  for_each = {
    file_upload = var.file_upload_bucket_name
    frontend_assest = var.frontend_bucket_name
  }
  bucket = each.value
}
