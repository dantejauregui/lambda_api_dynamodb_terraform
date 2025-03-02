provider "aws" {
  region = "eu-central-1"
}

module "lambda" {
  source           = "./modules/lambda"
  lambda_image_uri = var.lambda_image_uri
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name
}