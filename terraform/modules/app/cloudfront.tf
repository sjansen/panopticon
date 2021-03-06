resource "aws_cloudfront_distribution" "cdn" {
  provider = aws.us-east-1

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  tags            = var.tags

  aliases = [
    var.dns-name
  ]

  custom_error_response {
    error_code            = 400
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 500
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 502
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 503
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 504
    error_caching_min_ttl = 0
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "s3-bucket"
    // TODO: replace with a trusted key group once supported by terraform
    trusted_signers = ["self"]

    compress               = false
    default_ttl            = 86400
    max_ttl                = 604800
    min_ttl                = 0
    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_regional_domain_name
  }

  dynamic "ordered_cache_behavior" {
    for_each = toset(["/", "/whoami/", "/saml/*"])
    content {
      path_pattern     = ordered_cache_behavior.value
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = "APIGW"

      compress               = true
      default_ttl            = 0
      max_ttl                = 3600
      min_ttl                = 0
      viewer_protocol_policy = "redirect-to-https"

      forwarded_values {
        query_string = false
        cookies {
          forward = "all"
        }
        headers = [
          "Host",
        ]
      }
    }
  }

  origin {
    domain_name = trimsuffix(trimprefix(aws_api_gateway_stage.app.invoke_url, "https://"), "/default")
    origin_id   = "APIGW"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id   = "s3-bucket"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cloudfront-cert.certificate_arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "cdn" {
  provider = aws.us-east-1
  comment  = "OAI for ${var.dns-name}"
}
