output "rest_api_id" {
  value = aws_api_gateway_rest_api.rest_api.id
}

output "api_stage_name" {
  value = aws_api_gateway_stage.stage.stage_name
}
