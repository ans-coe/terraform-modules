variable "pat" {
  description = "This is the PAT token to connect to the ADO project"
}

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
    yml_path      = string
  }))

}