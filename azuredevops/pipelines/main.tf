data "azuredevops_project" "main" {
  name = var.project_name
}

data "azuredevops_git_repository" "main" {
  project_id = data.azuredevops_project.main.id
  name       = var.repo_name
}

locals {
  pipelines = { for p in var.pipelines : p.name => p }
}

resource "azuredevops_build_definition" "main" {
  for_each = local.pipelines

  project_id = data.azuredevops_project.main.id
  name       = each.key
  path       = each.value.path
  ci_trigger { use_yaml = true }
  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.main.id
    branch_name = each.value.branch_name
    yml_path    = "${each.value.config_path}/${each.value.file_name}"
  }
}

resource "azuredevops_branch_policy_build_validation" "main" {
  for_each = local.pipelines

  project_id = data.azuredevops_project.main.id

  enabled  = true
  blocking = true

  settings {
    display_name        = "${each.key} - Validation"
    build_definition_id = azuredevops_build_definition.main[each.key].id
    valid_duration      = 720
    filename_patterns = [
      "${each.value.config_path}/*.tf"
    ]

    scope {
      repository_id  = data.azuredevops_git_repository.main.id
      repository_ref = "refs/heads/main"
      match_type     = "Exact"
    }
  }
}