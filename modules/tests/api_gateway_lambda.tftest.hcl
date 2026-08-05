# Example: Basic terraform test structure
run "setup" {
  # Create the infrastructure
}

run "api_gateway_integration" {
    
    command = apply
    assert {
        condition     = lambda.target_arn == aws_lambda_function.api.arn
        error_message = "API Gateway must route to the correct Lambda."
    }
}

run "lambda_has_s3_access" {
  command = apply
  assert {
    condition     = contains(data.aws_iam_policy_document.lambda.statement[*].actions[*], "s3:GetObject")
    error_message = "Lambda IAM policy must include s3:GetObject."
  }
}

run "s3_bucket_encryption" {
  command = apply
  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.frontend.rules[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "S3 bucket must have encryption enabled."
  }
}
