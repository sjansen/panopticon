resource "aws_lambda_function" "app" {
  image_uri    = "${var.repo-urls["app"]}:latest"
  package_type = "Image"
  tags         = var.tags

  function_name = local.fn-names["app"]
  memory_size   = 128
  publish       = true
  role          = aws_iam_role.x["app"].arn
  timeout       = 15

  environment {
    variables = {
      PANOPTICON_BUCKET                 = aws_s3_bucket.media.id,
      PANOPTICON_CLOUDFRONT_KEY_ID      = "ssm"
      PANOPTICON_CLOUDFRONT_PRIVATE_KEY = "ssm"
      PANOPTICON_APP_URL                = "https://${var.dns-name}/"
      PANOPTICON_SAML_CERTIFICATE       = "ssm"
      PANOPTICON_SAML_METADATA_URL      = "ssm"
      PANOPTICON_SAML_PRIVATE_KEY       = "ssm"
      PANOPTICON_SESSION_TABLE          = aws_dynamodb_table.sessions.name
      PANOPTICON_SSM_PREFIX             = "/${var.ssm-prefix}/"
    }
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_cloudwatch_log_group.x["app"],
  ]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.app.execution_arn}/*/*"
}
