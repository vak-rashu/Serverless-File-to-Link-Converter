#create a dynamodb table with ttl enabled to store mapping of short code with the originalURL
resource "aws_dynamodb_table" "db" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "shortKey"
    attribute {
      name = "shortKey"
      type = "S"
    }

    ttl {
      attribute_name = "TimeToExist"
      enabled = true
    }
}

# output "myprojectlink" {
#   value = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.stage.stage_name}/shorten"

# }
