output "key_arn" {
  value = aws_kms_key.main.arn
}

output "key_id" {
  value = aws_kms_key.main.id
}

output "key_alias_id" {
  value = aws_kms_alias.main.arn
}

output "key_alias_arn" {
  value = aws_kms_alias.main.target_key_arn
}

output "policy" {
  value = data.aws_iam_policy_document.key_share.json
}