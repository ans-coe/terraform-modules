data "aws_iam_policy_document" "code_pipeline_role_policy" {
  statement {
    actions = [
      "s3:GetBucketVersioning"
    ]
    resources = [
      "${data.aws_s3_bucket.deployment.arn}",
      "${module.pipeline_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "${data.aws_s3_bucket.deployment.arn}/*",
      "${module.pipeline_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    resources = [
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

    resources = [var.key_arn]
  }

  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_role" {
  name   = "codepipeline_role_policy"
  role   = aws_iam_role.deployment_pipeline_role.id
  policy = data.aws_iam_policy_document.code_pipeline_role_policy.json
}