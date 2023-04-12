variable "name" {
  description = "Name of the Application"
  type        = string
}

variable "deployment_roles" {
  description = "List of ARNs of roles that will be used in the deployment steps."
  type        = list(string)
}

variable "branches" {
  description = "List of branch names to create pipelines for"
  type        = list(string)
}

variable "code_commit_repo" {
  description = "Name of the Code Commit Repo"
  type        = string
}