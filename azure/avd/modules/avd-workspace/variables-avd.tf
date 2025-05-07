variable "avd_workspace_name" {
  description = "value"
  type        = string
}

variable "location" {
  description = "Azure region to use."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "workspace_config" {
  description = "AVD Workspace specific configuration."
  type = object({
    friendly_name                 = optional(string)
    description                   = optional(string)
    public_network_access_enabled = optional(bool)
    extra_tags                    = optional(map(string))
  })
  default  = {}
  nullable = false
}
