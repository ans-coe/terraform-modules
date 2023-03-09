variable "repo_name" {
  default     = "terraform-configs"
  description = "The name of the repo"
}

variable "project_name" {
  default     = "Terraform-Ops"
  description = "The name of the project"
}

variable "pipelines" {
  type = list(object({
    pipeline_name = string
    pipeline_path = string
    config_path   = string
    file_name     = optional(string, "azure-pipelines.yml")
    branch_name   = optional(string, "main")
  }))
}