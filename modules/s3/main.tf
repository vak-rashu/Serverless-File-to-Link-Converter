#create a bucket resource
resource "aws_s3_bucket" "s3bucket"{
  for_each = {
    file_upload = var.upload_file_bucket_name
    frontend_assest = var.frontend_assests_bucket_name
  }
  bucket = each.value
}
