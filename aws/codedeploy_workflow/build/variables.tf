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
  default     = null
}

variable "create_code_commit_repo" {
  description = "Create a code commit repo"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Providing a KMS Key will stop one from being generated"
  type        = string
  default     = null
}

variable "enable_codepipeline" {
  description = "Whether to include the CodePipeline"
  type        = bool
  default     = true
}