data "aws_iam_policy_document" "AssumeRole-apigw" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "AssumeRole-lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "app-lambda" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
    ]
    resources = [aws_dynamodb_table.sessions.arn]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.media.arn,
      "${aws_s3_bucket.media.arn}/*",
    ]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = ["${aws_s3_bucket.media.arn}/inbox/*"]
  }
  statement {
    actions   = ["ssm:GetParameters"]
    resources = ["arn:aws:ssm:*:*:parameter/${var.ssm-prefix}/*"]
  }
}

resource "aws_iam_role" "apigw" {
  name = "${var.dns-name}-APIGateway"
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.AssumeRole-apigw.json
}

resource "aws_iam_role" "x" {
  for_each = local.lambdas

  name = "${var.dns-name}-${each.value}"
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.AssumeRole-lambda.json
}

resource "aws_iam_role_policy" "app" {
  name   = "all-the-things"
  role   = aws_iam_role.x["app"].name
  policy = data.aws_iam_policy_document.app-lambda.json
}

resource "aws_iam_role_policy_attachment" "apigw" {
  role       = aws_iam_role.apigw.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "lambda-logs" {
  for_each   = toset([for x in aws_iam_role.x : x.name])
  role       = each.value
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-xray" {
  for_each   = toset([for x in aws_iam_role.x : x.name])
  role       = each.value
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}
