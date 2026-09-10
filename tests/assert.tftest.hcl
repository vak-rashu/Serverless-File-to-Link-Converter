variables {
  upload_file_bucket_name = "User_bucket"
  frontend_assests_bucket_name = "Frontend_app"
}

mock_provider "aws" {}

run "unit_tests"{
    command = plan

    module {
      source = "../s3"
    }

    assert {
      condition = aws_s3_bucket.s3bucket.bucket == var.upload_file_bucket_name
      error_message = "The bucket name does not match"
    }

}

    # API Gateway — confirm throttling is actually configured, not just present
run "api_gateway_throttling_configured" {
  command = plan

  module {
    source = "../api-gw"
  }

  assert {
    condition     = aws_api_gateway_stage.stage.stage_name == "project"
    error_message = "Stage name does not match expected environment"
  }
}

# DynamoDB — confirm the partition key and TTL are set correctly
run "dynamodb_schema_correct" {
  command = plan

  module {
    source = "../dynamo-db"
  }

  assert {
    condition     = aws_dynamodb_table.db.hash_key == "shortKey"
    error_message = "Partition key does not match expected schema"
  }

  assert {
    condition     = aws_dynamodb_table.db.ttl[0].enabled == true
    error_message = "TTL is not enabled for auto-expiring links"
  }
}
# Lambda — check runtime and handler match what you intended
run "lambda_config_correct" {
  command = plan

  module {
    source = "../lambda"
  }

  assert {
    condition     = aws_lambda_function.lambda_func.runtime == "python3.12"
    error_message = "Lambda runtime does not match expected version"
  }

  assert {
    condition     = aws_lambda_function.lambda_func.handler == "lambda_function.lambda_handler"
    error_message = "Lambda handler is misconfigured"
  }
}
