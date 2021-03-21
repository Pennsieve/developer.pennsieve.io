# OUTPUT LAMBDA ARN
output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

# OUTPUT LAMBDA QUALIFIED ARN
output "lambda_function_qualified_arn" {
  value = aws_lambda_function.lambda_function.qualified_arn
}

# OUTPUT LAMBDA VERSION
output "lambda_function_version" {
  value = aws_lambda_function.lambda_function.version
}

# CLOUDFRONT DISTRIBUTION ID
output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cloudfront_distribution.id
}
