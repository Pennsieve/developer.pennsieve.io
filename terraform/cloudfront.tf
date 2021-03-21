# CREATE CLOUDFRONT ORIGIN ACCESS IDENTITY
resource "aws_cloudfront_origin_access_identity" "cloudfront_origin_access_identity" {
  comment = "${var.environment_name}-developer-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
}

# CREATE CLOUDFRONT DISTRIBUTION
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases = [
    "developer.${data.terraform_remote_state.account.outputs.domain_name}",
  ]

  comment             = aws_s3_bucket.s3_bucket.id
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_domain_name
    origin_id   = "${aws_s3_bucket.s3_bucket.id}S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.cloudfront_access_identity_path
    }
  }

  logging_config {
    include_cookies = false
    bucket          = data.terraform_remote_state.region.outputs.logs_s3_bucket_domain_name
    prefix          = "${var.environment_name}/developer/cloudfront/"
  }

  custom_error_response {
    error_code         = "404"
    response_page_path = "/404.html"
    response_code      = "404"
  }

  custom_error_response {
    error_code         = "403"
    response_page_path = "/404.html"
    response_code      = "403"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 3600
    max_ttl                = 86400
    min_ttl                = 0
    target_origin_id       = "${aws_s3_bucket.s3_bucket.id}S3Origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin",
      ]
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.lambda_function.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    aws_account      = var.aws_account
    aws_region       = data.aws_region.current_region.name
    environment_name = var.environment_name
    Name             = "${var.environment_name}-developer-cloudfront-distribution-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
    name             = "${var.environment_name}-developer-cloudfront-distribution-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
    service_name     = var.service_name
    tier             = "cloudfront-distribution"
  }

  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.region.outputs.wildcard_cert_arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }
}

# CREATE CLOUDFRONT INVALIDATION
resource "null_resource" "create_invalidation" {
  triggers = {
    f404_object_etag = aws_s3_bucket_object.f404_object.etag
    lambda_arn       = aws_lambda_function.lambda_function.qualified_arn
  }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.cloudfront_distribution.id} --paths \"/*\""
  }
}
