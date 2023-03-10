variable "repo_name" {
  default     = "terraform-configs"
  description = "The name of the repo"
}

variable "project_name" {
  default     = "Terraform-Ops"
  description = "The name of the project"
}

variable "pipelines" {
  description = "A list of objects that each contain a definition for a pipeline"

  type = list(object({
    name = string
    path = optional(string)
    config_path   = string
    file_name     = optional(string, "azure-pipelines.yml")
    branch_name   = optional(string, "main")
  }))
}