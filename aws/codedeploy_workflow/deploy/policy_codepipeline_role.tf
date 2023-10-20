data "aws_iam_policy_document" "code_pipeline_role_policy" {
  count = var.enable_codepipeline ? 1 : 0
  statement {
    actions = [
      "s3:GetBucketVersioning"
    ]
    resources = [
      data.aws_s3_bucket.deployment.arn,
      "${module.pipeline_bucket[0].s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "${data.aws_s3_bucket.deployment.arn}/*",
      "${module.pipeline_bucket[0].s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    resources = [
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
    resources = [
      aws_codedeploy_app.deploy_app.arn,
      aws_codedeploy_deployment_group.deployment_group.arn,
      "arn:aws:codedeploy:eu-west-1:${data.aws_caller_identity.current.account_id}:deploymentconfig:*"
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_role" {
  count  = var.enable_codepipeline ? 1 : 0
  name   = "codepipeline_role_policy"
  role   = aws_iam_role.deployment_pipeline_role[0].id
  policy = data.aws_iam_policy_document.code_pipeline_role_policy[0].json
}