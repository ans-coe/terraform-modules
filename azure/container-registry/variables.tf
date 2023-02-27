###################
# Global Variables
###################

variable "location" {
  description = "The location of created resources."
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

######
# ACR
######

variable "name" {
  description = "Name of the ACR."
  type        = string
}

variable "sku" {
  description = "SKU of the ACR."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The sku must be 'Basic', 'Standard' or 'Premium'."
  }
}

variable "enable_public_access" {
  description = "Enable public access to ACR."
  type        = bool
  default     = true
}

variable "enable_export_policy" {
  description = "Enable export policy. Requires 'Premium' SKU. Requires public access to be disabled if false."
  type        = bool
  default     = true
}

variable "enable_anonymous_pull" {
  description = "Enable anonymous pull."
  type        = bool
  default     = false
}

variable "enable_data_endpoint" {
  description = "Enable data endpoint."
  type        = bool
  default     = false
}

variable "enable_quarantine_policy" {
  description = "Enable quarantine policy. Requires 'Premium' SKU."
  type        = bool
  default     = false
}

variable "enable_zone_redundancy" {
  description = "Enable zone redundancy. Requires 'Premium' SKU."
  type        = bool
  default     = false
}

variable "enable_trust_policy" {
  description = "Enable trust policy. Requires 'Premium' SKU."
  type        = bool
  default     = false
}

variable "enable_retention_policy" {
  description = "Enable retention policy. Requires 'Premium' SKU."
  type        = bool
  default     = false
}

variable "retention_policy_days" {
  description = "Days to retain untagged manifests."
  type        = number
  default     = 7
}

variable "allowed_cidrs" {
  description = "CIDR ranges allowed access to this ACR."
  type        = set(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Subnet IDs allowed access to this ACR."
  type        = set(string)
  default     = []
}

variable "georeplications" {
  description = "List of objects representing georeplications."
  type = list(object({
    location                 = string
    enable_regional_endpoint = optional(bool, false)
    enable_zone_redundancy   = optional(bool, false)
  }))
  default = []
}

variable "encryption" {
  description = "Encryption configuration."
  type = object({
    vault_key_id       = string
    identity_client_id = string
  })
  default = null
}

variable "identity_ids" {
  description = "Managed identity IDs to assign to this ACR."
  type        = list(string)
  default     = []
}

variable "pull_object_ids" {
  description = "Object IDs to grant the pull permission to."
  type        = list(string)
  default     = []
}

variable "push_object_ids" {
  description = "Object IDs to grant the push permission to."
  type        = list(string)
  default     = []
}

###########
# Webhooks
###########

variable "webhooks" {
  description = "Definitions for webhooks to create for this ACR."
  type = list(object({
    name    = string
    uri     = string
    actions = list(string)
    enabled = optional(bool, true)
    scope   = optional(string)
    headers = optional(map(string), {})
  }))
  default = []
}

##############
# Agent Pools
##############

variable "agent_pools" {
  description = "Definitions for agent pools to create for this ACR."
  type = list(object({
    name      = string
    instances = optional(number, 1)
    tier      = optional(string, "S1")
    subnet_id = optional(string)
  }))
  default = []
}

#############
# Scope Maps
#############

variable "scope_maps" {
  description = "Scope maps to create for this ACR."
  type = list(object({
    name        = string
    description = optional(string)
    actions     = set(string)
  }))
  default = []
}
