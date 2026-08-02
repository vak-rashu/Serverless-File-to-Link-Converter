#create a zip file for go
data "archive_file" "zip_file_lambda" {
  type = "zip"
  source_dir = var.source_dir
  output_path = var.output_path
}

#create lambda function
resource "aws_lambda_function" "lambda_func" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler" 
  runtime       = var.runtime_type                         
  filename         = var.output_path
  source_code_hash = filebase64sha256(var.output_path)

  environment {
    variables = {
      TABLE_NAME = var.dynamo_table_name
      API_ID = aws_api_gateway_rest_api.rest_api.id
      BUCKET_NAME = var.bucket_name
    }
  }
}
