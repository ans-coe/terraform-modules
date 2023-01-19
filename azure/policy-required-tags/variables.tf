variable "name" {
  description = "Name of the policy."
  type        = string
  default     = "required_tags"
}

variable "display_name" {
  description = "Display name of the policy."
  type        = string
  default     = "Required Tags"
}

variable "management_group_id" {
  description = "The management group ID to use when creating this policy definition. If blank, applies to target subscription."
  type        = string
  default     = null
}

variable "scopes" {
  description = "The scopes that the policy will be assigned to."
  type        = list(string)
  default     = []
}

variable "exclude_scopes" {
  description = "Target scopes that are excluded from the policy assignment. Only affects management group and subscription scopes."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "The key of each tag that will be configured for policy."
  type        = list(string)
  default     = []
}

variable "enforce" {
  description = "Controls the enforcement of the policy."
  type        = bool
  default     = false
}
