# CREATE APP S3 BUCKET
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "pennsieve-${var.environment_name}-developer-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  policy = data.aws_iam_policy_document.iam_policy_document.json

  lifecycle {
    prevent_destroy = "false"
  }

  logging {
    target_bucket = data.terraform_remote_state.region.outputs.logs_s3_bucket_id
    target_prefix = "${var.environment_name}/developer/s3/"
  }

  tags = {
    aws_account      = var.aws_account
    aws_region       = data.aws_region.current_region.name
    environment_name = var.environment_name
    Name             = "${var.environment_name}-developer-s3-bucket-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
    name             = "${var.environment_name}-developer-s3-bucket-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
    service_name     = var.service_name
    tier             = "s3"
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3600
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# CREATE 404.HTML
resource "aws_s3_bucket_object" "f404_object" {
  bucket       = aws_s3_bucket.s3_bucket.id
  key          = "404.html"
  source       = "${path.module}/404.html"
  etag         = md5(file("${path.module}/404.html"))
  content_type = "text/html"
}
