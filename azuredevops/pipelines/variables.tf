variable "repo_name" {
  description = "The name of the repo"
  type        = string
  default     = "terraform-configs"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "Terraform-Ops"
}

variable "pipelines" {
  description = "A list of objects that each contain a definition for a pipeline"
  type = list(object({
    name        = string
    path        = optional(string)
    config_path = string
    file_name   = optional(string, "azure-pipelines.yml")
    branch_name = optional(string, "main")
  }))
}