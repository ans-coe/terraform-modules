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
    tags = var.tags
  }
}

locals {
  name = "cdw-main-example"
}

### Example

module "build" {
  source = "../../build"
  name   = local.name

  code_commit_repo = aws_codecommit_repository.main.repository_name

  // Pass in a list of branches on the code commit repo that is used to trigger the build pipeline
  branches = [
    module.prod_deploy.branch,
  ]

  // Pass in the deployment role to grant it access to the bucket
  deployment_roles = [
    module.prod_deploy.deployment_role
  ]
}

module "prod_deploy" {
  source = "../../deploy"

  providers = {
    aws     = aws // In this example, the account we are deploying to is the same as the account we build in
    aws.src = aws // Pass in the account with the build pipeline
  }

  name = local.name
  asg_list = [
    aws_autoscaling_group.main.name
  ]

  // Pass in the branch of the CodeCommit
  branch = "prod"

  // Pass in variables from the build stage
  key_arn                = module.build.key_arn
  deployment_bucket_name = module.build.bucket_name
}