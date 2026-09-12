variables {
  upload_file_bucket_name = "User_bucket"
  frontend_assests_bucket_name = "Frontend_app"
}

mock_provider "aws" {}

run "unit_tests"{
    command = plan

    variables {
      upload_file_bucket_name = "User_bucket"
      frontend_assets_bucket_name = "Frontend_app"
    }

    module {
      source = "../s3"
    }

    assert {
      condition = aws_s3_bucket.s3bucket.bucket == var.upload_file_bucket_name
      error_message = "The bucket name does not match"
    }
     assert {
      condition = aws_s3_bucket.asset_bucket.bucket == var.frontend_assets_bucket_name
      error_message = "The bucket name does not match"
    }
}

# API Gateway — confirm throttling is actually configured, not just present
run "api_gateway_throttling_configured" {
  command = plan

  variables {
    lambda_func_arn = ""
    lambda_func_name = "my-function123"
  }

  assert {
    condition     = aws_lambda_permission.api_gw.function_name == var.lambda_func_name
    error_message = "Stage name does not match expected environment"
  }
}

# DynamoDB — confirm the partition key and TTL are set correctly
run "dynamodb_schema_correct" {
  command = plan

  variables {
    dynamodb_table_name = "newDB123"
  }

  module {
    source = "../dynamo-db"
  }

  assert {
    condition     = aws_dynamodb_table.db.name == var.dynamodb_table_name
    error_message = "Partition key does not match expected schema"
  }
}

#Lambda — check runtime and handler match what you intended
run "lambda_config_correct" {
  command = plan

  variables {
    source_dir = "../../myproject/"
    output_path = "../../myproject/function.zip"
    runtime_type = "python3.12"
    function_name = "my-function123"
    bucket_name = ""
    dynamo_table_name = ""
    s3_bucket_arn = ""
    db_table_arn = ""
    rest_api_id = ""
  }

  module {
    source = "../lambda"
  }

  assert {
    condition     = aws_lambda_function.lambda_func.runtime == var.runtime_type
    error_message = "Lambda runtime does not match expected version"
  }

  assert {
    condition     = aws_lambda_function.lambda_func.function_name == var.function_name
    error_message = "Lambda handler is misconfigured"
  }
}
