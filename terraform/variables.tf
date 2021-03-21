variable "aws_account" {}

variable "environment_name" {}

variable "service_name" {}

variable "version_number" {}

variable "vpc_name" {}

variable "lambda_bucket" {
  default = "pennsieve-cc-lambda-functions-use1"
}

variable "runtime" {
  default = "nodejs12.x"
}

variable "is_ipv6_enabled" {
  default = false
}
