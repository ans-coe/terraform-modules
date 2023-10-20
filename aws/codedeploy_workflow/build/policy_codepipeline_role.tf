data "aws_iam_policy_document" "codepipeline_role_policy" {
  count = var.enable_codepipeline ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
    ]

    resources = [
      module.deploy_bucket.s3_bucket_arn,
      "${module.deploy_bucket.s3_bucket_arn}/*",
      module.pipeline_bucket[0].s3_bucket_arn,
      "${module.pipeline_bucket[0].s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [var.kms_key_arn != null ? var.kms_key_arn : module.kms_key[0].key_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]

    resources = [var.create_code_commit_repo ? aws_codecommit_repository.main[0].arn : data.aws_codecommit_repository.main[0].arn]
  }
}

resource "aws_iam_role_policy" "codepipeline_role" {
  count  = var.enable_codepipeline ? 1 : 0
  name   = "codepipeline_role_policy"
  role   = aws_iam_role.codepipeline_role[0].id
  policy = data.aws_iam_policy_document.codepipeline_role_policy[0].json
}