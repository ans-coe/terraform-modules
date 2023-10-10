data "aws_iam_policy_document" "key_share" {
  statement {
    sid = "Enable IAM User Permission"
    principals {
      type        = "AWS"
      identifiers = local.src_list
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = local.remotes ? [0] : []
    content {
      sid = "Allow use of the key by remotes"
      principals {
        type        = "AWS"
        identifiers = local.dest_list
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }
  dynamic "statement" {
    for_each = local.remotes ? [0] : []
    content {
      sid = "Allow attachment of persistent resources by remotes"
      principals {
        type        = "AWS"
        identifiers = local.dest_list
      }
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]
      resources = ["*"]
      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
    }
  }
}