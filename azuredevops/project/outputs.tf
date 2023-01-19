#################
# Project Details
#################

output "id" {
  description = "ID of the created project."
  value       = azuredevops_project.main.id
}

output "name" {
  description = "Name of the created project."
  value       = azuredevops_project.main.name
}

#####################
# Repository Details
#####################

output "repositories" {
  description = "Output of project repositories."
  value = {
    for r in data.azuredevops_git_repositories.all.repositories
    : r.name => r
  }
}
