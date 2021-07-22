output "fn-arns" {
  value = {
    app = aws_lambda_function.app.arn
  }
}

output "fn-names" {
  value = {
    app = aws_lambda_function.app.function_name
  }
}

output "media-bucket" {
  value = aws_s3_bucket.media.id
}
