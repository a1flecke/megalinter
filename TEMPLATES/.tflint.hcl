// https://github.com/terraform-linters/tflint/blob/master/docs/guides/config.md
config {
  module = false
  force = false
}

plugin "aws" {
  enabled = true
  version = "0.13.3"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  deep_check = false
}

rule "aws_instance_invalid_type" {
  enabled = false
}

rule "aws_instance_previous_type" {
  enabled = false
}

