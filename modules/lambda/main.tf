#lambda iam role
resource "aws_iam_role" "lambda_exec_role" {
    name = "lambda_exec_role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

#give that iam role permissions to access dynamodb and s3
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["logs:*"],
        Resource = "arn:aws:logs:*:*:*",
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject"],
        Resource = "${var.s3_bucket_arn}/*",
      },
      {
        Effect = "Allow",
        Action = ["dynamodb:PutItem", "dynamodb:GetItem"],
        Resource = var.db_table_arn,
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn

}

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
      API_ID = var.rest_api_id
      BUCKET_NAME = var.bucket_name
    }
  }
}
