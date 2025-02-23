output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.hello_api.id}.execute-api.eu-central-1.amazonaws.com/prod/hello"
}