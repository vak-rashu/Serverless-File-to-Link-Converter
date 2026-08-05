output "rest_api_id" {
  value = aws_api_gateway_rest_api.rest_api.id
}

output "api_stage_name" {
  value = aws_api_gateway_stage.stage.stage_name
}

output "api_gateway_short_uri" {
  value = aws_api_gateway_integration.integration_short.uri
}

output "api_gateway_shorten_uri" {
  value = aws_api_gateway_integration.integration_shorten.uri
}