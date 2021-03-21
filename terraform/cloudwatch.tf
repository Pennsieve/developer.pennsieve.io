# CREATE CLOUDWATCH EVENT RULE
resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name                = "${var.environment_name}-directory-index-lambda-edge-rule-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  description         = "Keep ${var.service_name} lambda function warm."
  schedule_expression = "cron(0/4 11-23 ? * MON-FRI *)"
}

# CREATE CLOUDWATCH EVENT TARGET
resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  target_id = "${var.environment_name}-directory-index-lambda-edge-target-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  rule      = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
  arn       = aws_lambda_function.lambda_function.qualified_arn
}
