data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_s3_bucket" "deployment" {
  provider = aws.src
  bucket   = var.deployment_bucket_name
}