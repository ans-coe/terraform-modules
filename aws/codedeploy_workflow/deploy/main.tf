
# Lifecycle Hooks Maybe?

locals {
  name = "${var.name}-${var.branch}-deploy"
}

resource "aws_iam_role" "deployment_pipeline_role" {
  count = var.enable_deployment_pipeline_role == true ? 1 : 0
  name               = "${local.name}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_codepipeline.json
}

module "pipeline_bucket" {
  count = var.enable_pipeline_bucket == true ? 1 : 0
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.name}-pipeline-bucket"
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_codepipeline" "codepipeline" {
  count = var.enable_codepipeline == true ? 1 : 0
  name = "${local.name}-pipeline"
  # role_arn = var.iam_role
  role_arn = aws_iam_role.deployment_pipeline_role.arn

  artifact_store {
    location = module.pipeline_bucket.s3_bucket_id
    type     = "S3"

    encryption_key {
      id   = var.key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        S3Bucket    = data.aws_s3_bucket.deployment.bucket
        S3ObjectKey = "${var.branch}-latest.zip"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToWebServer"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["SourceOutput"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.deploy_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
      }
    }
  }
}