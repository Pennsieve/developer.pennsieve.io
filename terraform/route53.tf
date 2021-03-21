# CREATE ROUTE53 ALIAS
resource "aws_route53_record" "route53_record" {
  zone_id = data.terraform_remote_state.account.outputs.public_hosted_zone_id
  name    = "developer.${data.terraform_remote_state.account.outputs.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
