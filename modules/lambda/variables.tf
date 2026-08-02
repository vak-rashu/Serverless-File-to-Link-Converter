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

variable "source_dir" {
  type = string
  description = "Lambda Function Zip Source Path"
}

variable "output_path" {
  type = string
  description = "Lambda Function Zip Destination Path"
}