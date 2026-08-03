variable "function_name" {
  type = string
  description = "Lambda Function Name"
}

variable "runtime_type" {
  type = string
  description = "Function Runtime Type"
}

variable "bucket_name" {
  type = string
  description = "S3 Bucket Name"
}

variable "dynamo_table_name" {
  type = string
  description = "DynamoDB Table Name"
}

variable "s3_bucket_arn" {
  type = string
  description = "S3 Bucket ARN"
}

variable "db_table_arn" {
  type = string
  description = "DB Table ARN"
}

variable "rest_api_id" {
  type = string
  description = "Rest API ID"
}

variable "source_dir" {
  type = string
  description = "Lambda Function Zip Source Path"
}

variable "output_path" {
  type = string
  description = "Lambda Function Zip Destination Path"
}
