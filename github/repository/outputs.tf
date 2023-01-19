#########################
# Repository information
#########################

output "name" {
  description = "Name of the repository."
  value       = github_repository.main.name
}

output "default_branch" {
  description = "Default branch of the repository."
  value       = github_branch_default.main.branch
}

output "web_url" {
  description = "URL of the repository."
  value       = github_repository.main.html_url
}

output "clone_url_http" {
  description = "URL to clone the repository using HTTPS."
  value       = github_repository.main.http_clone_url
}

output "clone_url_ssh" {
  description = "URL to clone the repository using SSH."
  value       = github_repository.main.ssh_clone_url
}
