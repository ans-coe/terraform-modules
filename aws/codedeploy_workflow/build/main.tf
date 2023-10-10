locals {
  pipeline_name = "${var.name}-build"
}

module "kms_key" {
  count            = var.kms_key_arn == null ? 1 : 0
  source           = "../../kms_key"
  key_name         = "${local.pipeline_name}-kms-key"
  dest_account_ids = data.aws_arn.deployment_role[*].account
  dest_iam_roles   = var.deployment_roles
  src_account_id   = data.aws_caller_identity.current.account_id
  src_iam_roles    = [try(aws_iam_role.codepipeline_role[0].arn, null)]
}

resource "aws_iam_role" "codepipeline_role" {
  count              = var.enable_codepipeline ? 1 : 0
  name               = "${local.pipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

module "pipeline_bucket" {
  count   = var.enable_codepipeline ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"

  bucket = "${local.pipeline_name}-pipeline-bucket"
  acl    = "private"

  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_key_arn != null ? var.kms_key_arn : module.kms_key[0].key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "deploy_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"

  bucket = "${local.pipeline_name}-deploy-bucket"
  acl    = "private"

  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_key_arn != null ? var.kms_key_arn : module.kms_key[0].key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_codecommit_repository" "main" {
  count = var.create_code_commit_repo ? 1 : 0

  repository_name = var.code_commit_repo
}

resource "aws_codepipeline" "codepipeline" {
  for_each = var.enable_codepipeline ? toset(var.branches) : toset([])

  name     = "${local.pipeline_name}-${each.value}-pipeline"
  role_arn = aws_iam_role.codepipeline_role[0].arn

  artifact_store {
    location = module.pipeline_bucket[0].s3_bucket_id
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn != null ? var.kms_key_arn : module.kms_key[0].key_arn
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
        RepositoryName       = var.create_code_commit_repo ? aws_codecommit_repository.main[0].repository_name : data.aws_codecommit_repository.main[0].repository_name
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