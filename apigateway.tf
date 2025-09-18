# API Gateway v2 (HTTP API)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "tts-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.tts.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "synthesize" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /synthesize"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# OPTIONS /synthesize route
resource "aws_apigatewayv2_route" "synthesize_options" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "OPTIONS /synthesize"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tts.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Allow Terraform to discover account ID
data "aws_caller_identity" "current" {}
