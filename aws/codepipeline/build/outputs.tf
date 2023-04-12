output "bucket_name" {
  description = "Name of the deployment bucket"
  value       = module.deploy_bucket.s3_bucket_id
}

output "key_arn" {
  description = "The ARN of the KMS Key"
  value       = module.kms_key.key_arn
}

