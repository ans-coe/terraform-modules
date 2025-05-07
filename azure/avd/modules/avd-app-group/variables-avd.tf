variable "avd_app_group_name" {
  description = "value"
  type        = string
}

variable "host_pool_id" {
  description = "Resource ID for a Virtual Desktop Host Pool to associate with the Virtual Desktop Application Group."
  type        = string
}

variable "application_group_config" {
  description = "AVD Application Group specific configuration."
  type = object({
    friendly_name                = optional(string)
    default_desktop_display_name = optional(string)
    description                  = optional(string)
    type                         = optional(string, "Desktop")
    role_assignments_object_ids  = optional(list(string), [])
    extra_tags                   = optional(map(string))
  })
  default  = {}
  nullable = false
}

variable "workspace_id" {
  description = "The resource ID for the Virtual Desktop Workspace."
  type        = string
}