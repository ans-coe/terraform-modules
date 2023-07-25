terraform {
  # Required per-provider as this module is not under hashicorp/*
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.6"
    }
  }
}

data "azuredevops_users" "all" {
  subject_types = ["aad", "msa"]
}

module "project" {
  source = "../../"

  name        = "terraform-module-example-advanced-project"
  description = "Example project created and managed through Terraform."

  repositories = ["repo1", "repo2"]
  teams = {
    "app1" = {
      description = "Application 1"
      # Generally speaking, this will probably be more tightly scoped.
      # This is just here for example purposes.
      administrators = data.azuredevops_users.all.users[*].descriptor
      members        = data.azuredevops_users.all.users[*].descriptor
    },
    "app2" = {
      description = "Application 2"
    },
    "app3" = {
      description    = "Application 3"
      administrators = data.azuredevops_users.all.users[*].descriptor
    }
  }
  teams_membership_mode = "add"

  environments = {
    "default" = {
      description = "Default Environment"
    },
    "dev" = {},
    "test" = {
      approval = {
        approvers             = data.azuredevops_users.all.users[*].id
        requester_can_approve = true
      }
      allowed_branches = { branches = "refs/heads/main, refs/heads/releases/*" }
    },
    "prod" = {
      approval = {
        approvers     = data.azuredevops_users.all.users[*].id
        min_approvers = 2
        instructions  = "This is production. Think about this!"
      }
      allowed_branches = { branches = "refs/heads/main, refs/heads/releases/*" }
    }
  }

  author_email_policy = {
    blocking         = false
    email_patterns   = ["*.example.com", "*.outlook.com"]
    repository_names = ["repo1"]
  }

  file_path_policy = {
    blocking         = false
    denied_paths     = ["dont_create", "bad_file"]
    repository_names = ["repo2"]
  }

  reserved_names_policy = {
    blocking = true
  }

  case_enforcement_policy = {}

  path_length_policy = {
    blocking        = false
    max_path_length = 550
  }

  file_size_policy = {
    blocking      = true
    max_file_size = 100
  }

  review_policy = {
    blocking           = false
    repository_names   = ["repo1"]
    submitter_can_vote = true
  }

  work_item_policy = {
    blocking = false
  }

  comment_policy = {
    blocking = false
  }
}

output "repositories" {
  description = "Output of repositories."
  value       = module.project.repositories
  sensitive   = true # Setting to sensitive as output is large.
}
