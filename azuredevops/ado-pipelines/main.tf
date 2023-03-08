data "azuredevops_project" "main" {
  name = var.project_name
}

data "azuredevops_git_repository" "main" {
  project_id = data.azuredevops_project.main.id
  name       = var.repo_name
}

resource "azuredevops_build_definition" "main" {
  for_each = { for p in var.pipelines : p.pipeline_name => p }

  project_id = data.azuredevops_project.main.id
  name       = each.key
  path       = each.value.pipeline_path
  ci_trigger { use_yaml = true }
  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.main.id
    branch_name = "main"
    yml_path    = each.value.yml_path
  }
}