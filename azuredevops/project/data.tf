data "azuredevops_git_repositories" "all" {
  project_id     = azuredevops_project.main.id
  include_hidden = true

  depends_on = [azuredevops_git_repository.main]
}
