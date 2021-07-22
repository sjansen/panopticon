resource "aws_api_gateway_account" "apigw" {
  cloudwatch_role_arn = aws_iam_role.apigw.arn
}

resource "aws_api_gateway_base_path_mapping" "app" {
  api_id      = aws_api_gateway_rest_api.app.id
  stage_name  = aws_api_gateway_stage.app.stage_name
  domain_name = aws_api_gateway_domain_name.app.domain_name
}

resource "aws_api_gateway_domain_name" "app" {
  domain_name              = var.dns-name
  regional_certificate_arn = aws_acm_certificate_validation.apigw-cert.certificate_arn
  security_policy          = "TLS_1_2"
  tags                     = var.tags

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "app" {
  rest_api_id = join("", aws_api_gateway_rest_api.app.*.id)

  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    redeployment = sha1(jsonencode([
      aws_lambda_function.app.version,
      aws_api_gateway_integration.app.id,
      aws_api_gateway_integration.app.id,
      aws_api_gateway_method.app.id,
      aws_api_gateway_method.app.id,
      aws_api_gateway_resource.app.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.app,
    aws_api_gateway_integration.app_root,
  ]
}

resource "aws_api_gateway_integration" "app" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_method.app.resource_id
  http_method = aws_api_gateway_method.app.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.app.invoke_arn
}

resource "aws_api_gateway_integration" "app_root" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_method.app_root.resource_id
  http_method = aws_api_gateway_method.app_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.app.invoke_arn
}

resource "aws_api_gateway_method" "app" {
  rest_api_id   = aws_api_gateway_rest_api.app.id
  resource_id   = aws_api_gateway_resource.app.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Host" = true
  }
}

resource "aws_api_gateway_method" "app_root" {
  rest_api_id   = aws_api_gateway_rest_api.app.id
  resource_id   = aws_api_gateway_rest_api.app.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Host" = true
  }
}

resource "aws_api_gateway_method_settings" "app" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  stage_name  = aws_api_gateway_stage.app.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_api_gateway_resource" "app" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  parent_id   = aws_api_gateway_rest_api.app.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_rest_api" "app" {
  name = local.api_gateway_name
  tags = var.tags

  minimum_compression_size = 65536
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "app" {
  rest_api_id   = aws_api_gateway_rest_api.app.id
  deployment_id = aws_api_gateway_deployment.app.id
  stage_name    = "default"

  xray_tracing_enabled = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw.arn
    format          = <<EOT
$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] "$context.httpMethod $context.resourcePath $context.protocol" $context.status $context.responseLength $context.requestId
EOT
  }

  depends_on = [aws_cloudwatch_log_group.apigw]
}
