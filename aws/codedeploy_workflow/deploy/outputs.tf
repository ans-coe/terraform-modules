output "key_arn" {
  description = "The ARN of the KMS Key"
  value       = var.key_arn
}

output "branch" {
  description = "Branch Argument"
  value       = var.branch
}

output "deployment_role" {
  description = "Role used to deploy"
  value       = aws_iam_role.deployment_pipeline_role[0].arn
}

output "deployment_bucket_id" {
  description = "Bucket used for CodeDeploy"
  value       = module.pipeline_bucket[0].s3_bucket_id
}