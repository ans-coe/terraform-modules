variable "name" {
  description = "Name of the application"
  type        = string
}

variable "deployment_bucket_name" {
  description = "Name of the bucket where the source object is"
  type        = string
}

variable "branch" {
  description = "Branch name of the deployment"
  type        = string
}

variable "key_arn" {
  description = "The ARN of the KMS Key"
  type        = string
}

variable "asg_list" {
  description = "List of ASGs to deploy code to"
  type        = list(string)
}

variable "deployment_group" {
  description = "Variables relating to the deployment group"
  type = object({
    auto_rollback          = optional(bool, true)
    with_traffic_control   = optional(bool, false)
    blue_green             = optional(bool, false)
    deployment_config_name = optional(string, "CodeDeployDefault.AllAtOnce")
  })
  default = {}
}

variable "asg_loadbalancer_target_name" {
  description = "The Target group name for the loadbalancer. Required if deployment_group.blue_green is true"
  type        = string
  default     = null
}