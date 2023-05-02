data "aws_iam_policy_document" "codepipeline_role_policy" {
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
      module.pipeline_bucket.s3_bucket_arn,
      "${module.pipeline_bucket.s3_bucket_arn}/*"
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

    resources = [module.kms_key.key_arn]
  }

  statement {
    effect = "Allow"

    actions = ["codecommit:*"]

    resources = [data.aws_codecommit_repository.main.arn]
  }
}

resource "aws_iam_role_policy" "codepipeline_role" {
  name   = "codepipeline_role_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_role_policy.json
}