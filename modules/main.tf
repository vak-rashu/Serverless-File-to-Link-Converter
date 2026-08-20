module "s3bucket" {
  source                  = "./s3"
  upload_file_bucket_name = "newBucket123"
  frontend_assests_bucket_name    = "frontend_asses_bucket_name"
}

module "dynamodb" {
  source              = "./dynamo-db"
  dynamodb_table_name = "newDB123"
}

module "lambda_func" {
  source        = "./lambda"
  source_dir    = "../myproject/"
  output_path   = "../myproject/function.zip"
  runtime_type  = "python3.12"
  function_name = "my-function123"

  bucket_name       = module.s3bucket.file_upload_bucket_name
  dynamo_table_name = module.dynamodb.dynamo_table_name
  s3_bucket_arn     = module.s3bucket.file_upload_bucket_arn
  db_table_arn      = module.dynamodb.db_table_arn

  rest_api_id = module.api_gw.rest_api_id
}

module "api_gw" {
  source           = "./api-gw"
  lambda_func_arn  = module.lambda_func.lambda_func_invoke_arn
  lambda_func_name = module.lambda_func.lambda_func_name
}
