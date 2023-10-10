data "aws_s3_bucket" "deployment" {
  provider = aws.src
  bucket   = var.deployment_bucket_name
}