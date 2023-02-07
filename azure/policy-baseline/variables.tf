variable "management_group_id" {
  description = "The management group ID to use when creating the policies definition. If blank, applies to target subscription."
  type        = string
  default     = null
}

variable "scopes" {
  description = "The scopes that the policies will be assigned to."
  type        = list(string)
  default     = []
}

variable "exclude_scopes" {
  description = "Target scopes that are excluded from the policies assignment. Only affects management group and subscription scopes."
  type        = list(string)
  default     = []
}

variable "locations" {
  description = "The locations we will be allowed to deploy to."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "The key of each tag that will be configured for policy."
  type        = list(string)
  default     = []
}

variable "enforce" {
  description = "Controls the enforcement of the policies."
  type        = bool
  default     = false
}
