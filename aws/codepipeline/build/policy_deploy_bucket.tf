data "aws_iam_policy_document" "deploy_bucket" {
  statement {
    sid = "${var.name}-ReadAccess"
    principals {
      type = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root",
        concat(
          data.aws_arn.deployment_role.*.account,
          [data.aws_caller_identity.current.account_id]
        )
      )
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]

    resources = [
      module.deploy_bucket.s3_bucket_arn,
      "${module.deploy_bucket.s3_bucket_arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "deploy_bucket" {
  bucket = module.deploy_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.deploy_bucket.json
}