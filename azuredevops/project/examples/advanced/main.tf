terraform {
  # Required per-provider as this module is not under hashicorp/*
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.3.0"
    }
  }
}

data "azuredevops_users" "users" {
  subject_types = ["aad", "msa"]
}

module "project" {
  source = "../../"

  name        = "terraform-module-example-advanced-project"
  description = "Example project created and managed through Terraform."

  repository_names = ["repo1", "repo2"]
  teams = [
    {
      name           = "app1"
      description    = "Application 1"
      administrators = data.azuredevops_users.users.users[*].descriptor
      members        = [data.azuredevops_users.users.users[*].descriptor[0]]
    },
    {
      name        = "app2"
      description = "Application 2"
    },
    {
      name           = "app3"
      description    = "Application 3"
      administrators = data.azuredevops_users.users.users[*].descriptor
    }
  ]
  teams_membership_mode = "add"

  environments = [
    {
      name        = "default"
      description = "Default Environment"
    },
    {
      name = "dev"
    },
    {
      name = "test"
    },
    {
      name = "prod"
    }
  ]

  author_email_policy = {
    enabled          = true
    blocking         = false
    email_patterns   = ["*.example.com", "*.outlook.com"]
    repository_names = ["repo1"]
  }

  file_path_policy = {
    enabled          = true
    blocking         = false
    denied_paths     = ["dont_create", "bad_file"]
    repository_names = ["repo2"]
  }

  reserved_names_policy = {
    enabled  = true
    blocking = true
  }

  case_enforcement_policy = {
    enabled = true
  }

  path_length_policy = {
    enabled         = true
    blocking        = false
    max_path_length = 550
  }

  file_size_policy = {
    enabled       = true
    blocking      = true
    max_file_size = 100
  }

  review_policy = {
    enabled            = true
    blocking           = false
    repository_names   = ["repo1"]
    submitter_can_vote = true
  }

  work_item_policy = {
    enabled  = true
    blocking = false
  }

  comment_policy = {
    enabled  = true
    blocking = false
  }
}

output "repositories" {
  description = "Output of repositories."
  value       = module.project.repositories
  sensitive   = true # Setting to sensitive as output is large.
}
