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

variable "enable_codepipeline_role" {
  description = "Whether to include the CodePipeline role"
  type        = bool
  default     = true
}

variable "enable_kms_key" {
  description = "Whether to include the KMS key"
  type        = bool
  default     = true
}

variable "enable_pipeline_bucket" {
  description = "Whether to include the pipeline bucket"
  type        = bool
  default     = true
}

variable "enable_deploy_bucket" {
  description = "Whether to include the deploy bucket"
  type        = bool
  default     = true
}

variable "enable_codepipeline" {
  description = "Whether to include the CodePipeline"
  type        = bool
  default     = true
}