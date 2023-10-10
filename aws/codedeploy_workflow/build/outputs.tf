output "bucket_name" {
  description = "Name of the deployment bucket"
  value       = module.deploy_bucket.s3_bucket_id
}

output "key_arn" {
  description = "The ARN of the KMS Key"
  value       = var.kms_key_arn != null ? var.kms_key_arn : module.kms_key[0].key_arn
}

