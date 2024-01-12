resource "aws_iam_policy" "deployment_policy" {
  name        = "DeploymentPolicy"
  path        = "/"
  description = "Policy For Granting Access To The S3 Bucket For Deployment"
  policy      = data.aws_iam_policy_document.deployment_policy.json
}

data "aws_iam_policy_document" "deployment_policy" {
  // KMS Access
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [module.build.key_arn]
  }
  // Statements for s3 bucket
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]

    resources = [
      "arn:aws:s3:::${module.prod_deploy.deployment_bucket_id}",
      "arn:aws:s3:::${module.prod_deploy.deployment_bucket_id}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "deployment_policy" {
  policy_arn = aws_iam_policy.deployment_policy.arn
  role       = aws_iam_role.main.name
}