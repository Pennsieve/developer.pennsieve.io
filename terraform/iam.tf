# LAMBDA IAM ROLE
resource "aws_iam_role" "lambda_iam_role" {
  name = "${var.environment_name}-directory-index-lambda-edge-role-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# LAMBDA IAM ROLE POLICY
resource "aws_iam_role_policy" "lambda_iam_role_policy" {
  name = "${var.environment_name}-directory-index-lambda-edge-policy-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  role = aws_iam_role.lambda_iam_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Lambda",
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "CloudwatchLogPermissions",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutDestination",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

# S3 BUCKET POLICY
data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::pennsieve-${var.environment_name}-developer-${data.terraform_remote_state.region.outputs.aws_region_shortname}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::pennsieve-${var.environment_name}-developer-${data.terraform_remote_state.region.outputs.aws_region_shortname}"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.iam_arn]
    }
  }
}
