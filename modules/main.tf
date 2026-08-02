module "s3bucket" {
  source = "./s3"
  bucket_name = "enter-value-here"
}

module "dynamodb" {
  source = "./dynamo-db"
  dynamodb_table_name = "enter-here"
}

module "lambda_func" {
  source = "./lambda"
  source_dir = ""
  output_path = ""
  runtime_type = "python3.12"
  function_name = "enter-function-name"

  bucket_name = module.s3bucket.bucket_name
  dynamo_table_name = module.dynamodb.dynamo_table_name
}
