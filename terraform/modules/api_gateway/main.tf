variable "lambda_invoke_arn" {}
variable "lambda_function_name" {}

resource "aws_api_gateway_rest_api" "hello_api" {
  name        = "HelloWorldAPI"
  description = "API Gateway for Lambda Hello World"
}

resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.hello_api.id
  parent_id   = aws_api_gateway_rest_api.hello_api.root_resource_id
  path_part   = "hello"
}


#ApiGateway will support GET requests:
resource "aws_api_gateway_method" "hello_method" {
  rest_api_id   = aws_api_gateway_rest_api.hello_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}


#ApiGateway will support POST requests:
resource "aws_api_gateway_method" "hello_method_post" {
  rest_api_id   = aws_api_gateway_rest_api.hello_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "POST"
  authorization = "NONE"
}


#General Integration for Lambda & API Gateway for GETting data from OmDB ("integration_http_method" will be always POST, regardless of whether the client request is GET or POST):
resource "aws_api_gateway_integration" "lambda_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.hello_api.id
  resource_id             = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.hello_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn  # will use the values coming from the Lambda Outputs
}
# General Integration for Lambda & API Gateway for POSTing data to DynamoDB:
resource "aws_api_gateway_integration" "lambda_integration_post" {
  rest_api_id             = aws_api_gateway_rest_api.hello_api.id
  resource_id             = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.hello_method_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn  # will use the values coming from the Lambda Outputs
}



# General IAM Permission for Lambda for GET/POST using "/*/*"
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hello_api.execution_arn}/*/*"
}


# Ensuring both GET & POST integrations exist before deploying
resource "aws_api_gateway_deployment" "hello_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration_get, aws_api_gateway_integration.lambda_integration_post]
  rest_api_id = aws_api_gateway_rest_api.hello_api.id
}
resource "aws_api_gateway_stage" "hello_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.hello_api.id
  deployment_id = aws_api_gateway_deployment.hello_deployment.id
}