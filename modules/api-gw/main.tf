#creating a rest api
resource "aws_api_gateway_rest_api" "rest_api" {
  name = "myprojectAPI"
  description = "MyProject Rest API"
  binary_media_types = ["multipart/form-data"]
}

#creating the resource for shorten to post files
resource "aws_api_gateway_resource" "shorten" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "shorten"
}

#creating a method for the /shorten endpoint
resource "aws_api_gateway_method" "shorten_method" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id =  aws_api_gateway_resource.shorten.id
  http_method = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Content-Type" = true
    "method.request.header.Accept" = true
  }
}

# OPTIONS method for /shorten CORS preflight
resource "aws_api_gateway_method" "shorten_options" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.shorten.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

#creating integration for POST /shorten
resource "aws_api_gateway_integration" "integration_shorten" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id =  aws_api_gateway_resource.shorten.id
  http_method = aws_api_gateway_method.shorten_method.http_method
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = var.lambda_func_arn

  request_parameters = {
    "integration.request.header.Content-Type" = "method.request.header.Content-Type"
    "integration.request.header.Accept" = "method.request.header.Accept"
  }
}

# integration for OPTIONS /shorten
resource "aws_api_gateway_integration" "integration_shorten_options" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.shorten.id
  http_method             = aws_api_gateway_method.shorten_options.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_func_arn
}

resource "aws_api_gateway_resource" "short" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "short"
}

#alloting method to the path
resource "aws_api_gateway_method" "method" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.short.id
  http_method = "GET"
  authorization = "NONE"
}

#integrating the created api with lambda function
resource "aws_api_gateway_integration" "integration_short" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.short.id
  http_method = aws_api_gateway_method.method.http_method
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = var.lambda_func_arn
}

#make a deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [ 
    aws_api_gateway_integration.integration_shorten,
    aws_api_gateway_integration.integration_short,
   ]
   rest_api_id = aws_api_gateway_rest_api.rest_api.id  
}

#create a stage
resource "aws_api_gateway_stage" "stage" {
  stage_name = "project"
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id

}

#permission for lambda for apigw
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_func_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}
