resource "aws_kms_key" "main" {
  description         = "kms key decription"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.key_share.json
  tags                = merge(var.tags, tomap({ "ApplicationComponent" = "kms" }))
}

resource "aws_kms_alias" "main" {
  name          = format("alias/%s", var.key_name)
  target_key_id = aws_kms_key.main.key_id
}