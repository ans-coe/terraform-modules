terraform {
  required_version = "~> 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = local.tags
  }
}

locals {
  name = "kms-key"
  tags = {
    Module     = "aws-codedeploy-example"
    Example    = "advanced"
    Usage      = "demo"
    Department = "technical"
    Owner      = "Dee Vops"
  }
}

data "aws_caller_identity" "current" {}

// The below module will create a KMS key and then give the caller's arn access to the key. 

module "kms_key" {
  source   = "../../"
  key_name = "${local.name}-kms-key"

  // Specify the account where the KMS Key is created
  src_account_id = data.aws_caller_identity.current.account_id

  // Specify the local IAM roles that you want to have access to the key
  src_iam_roles = [data.aws_caller_identity.current.arn]

  // Specify the remote accounts that you want to access the role
  dest_account_ids = []

  // Specify the remote IAM roles that you want to have access to the key
  dest_iam_roles = []
}