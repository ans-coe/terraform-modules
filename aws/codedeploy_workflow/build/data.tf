data "aws_caller_identity" "current" {}

data "aws_codecommit_repository" "main" {
  repository_name = var.code_commit_repo
}

data "aws_arn" "deployment_role" {
  count = length(var.deployment_roles)
  arn   = element(var.deployment_roles, count.index)
}

# data.aws_arn.deployment_role.*.account