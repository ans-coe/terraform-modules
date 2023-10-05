locals {
  pipeline_name = "${var.name}-build"
}

resource "aws_iam_role" "codepipeline_role" {
  count              = var.enable_codepipeline_role == true ? 1 : 0
  name               = "${local.pipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

module "kms_key" {
  count            = var.enable_kms_key == true ? 1 : 0
  source           = "../../kms_key"
  key_name         = "${local.pipeline_name}-kms-key"
  dest_account_ids = data.aws_arn.deployment_role.*.account
  dest_iam_roles   = var.deployment_roles
  src_account_id   = data.aws_caller_identity.current.account_id
  src_iam_roles    = [aws_iam_role.codepipeline_role[0].arn]
}

module "pipeline_bucket" {
  count  = var.enable_pipeline_bucket == true ? 1 : 0
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.pipeline_name}-pipeline-bucket"
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
        kms_master_key_id = module.kms_key.key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "deploy_bucket" {
  count  = var.enable_deploy_bucket == true ? 1 : 0
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.pipeline_name}-deploy-bucket"
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
        kms_master_key_id = module.kms_key.key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_codepipeline" "codepipeline" {
  for_each = var.enable_codepipeline == true ? toset(var.branches) : toset([])

  name     = "${local.pipeline_name}-${each.value}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = module.pipeline_bucket.s3_bucket_id
    type     = "S3"

    encryption_key {
      id   = module.kms_key.key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        PollForSourceChanges = true
        RepositoryName       = data.aws_codecommit_repository.main.repository_name
        BranchName           = each.value
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToS3"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["SourceOutput"]
      version         = "1"

      configuration = {
        BucketName = module.deploy_bucket.s3_bucket_id
        ObjectKey  = "${each.value}-latest.zip"
        Extract    = false
      }
    }
  }
}