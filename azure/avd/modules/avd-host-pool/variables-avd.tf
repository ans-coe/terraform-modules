variable "avd_host_pool_name" {
  description = "value"
  type        = string
}

variable "host_pool_config" {
  description = "AVD Host Pool specific configuration."
  type = object({
    friendly_name                         = optional(string)
    description                           = optional(string)
    validate_environment                  = optional(bool, true)
    custom_rdp_properties                 = optional(string, "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1;")
    public_network_access                 = optional(string, "Enabled")
    type                                  = optional(string, "Pooled")
    load_balancer_type                    = optional(string, "BreadthFirst")
    personal_desktop_assignment_type      = optional(string, "Automatic")
    maximum_sessions_allowed              = optional(number, 16)
    preferred_app_group_type              = optional(string)
    start_vm_on_connect                   = optional(bool, false)
    host_registration_expires_in_in_hours = optional(number, 48)
    scheduled_agent_updates = optional(object({
      enabled                   = optional(bool, false)
      timezone                  = optional(string, "UTC") # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
      use_session_host_timezone = optional(bool, false)
      schedules = optional(list(object({
        day_of_week = string
        hour_of_day = number
      })), [])
    }), {})
    extra_tags = optional(map(string))
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.host_pool_config.host_registration_expires_in_in_hours >= 2
    error_message = "`var.host_pool_config.host_registration_expires_in_in_hours` must be at least two hour from now."
  }
  validation {
    condition     = var.host_pool_config.host_registration_expires_in_in_hours <= 720
    error_message = "`var.host_pool_config.host_registration_expires_in_in_hours` must be no more than 720 hours (30 days) from now."
  }
  validation {
    condition     = var.host_pool_config.scheduled_agent_updates.enabled ? length(var.host_pool_config.scheduled_agent_updates.schedules) == 1 || length(var.host_pool_config.scheduled_agent_updates.schedules) == 2 : true
    error_message = "When `var.host_pool_config.scheduled_agent_updates.enabled = true`, at least one and up to 2 maintenance windows can be defined, got ${length(var.host_pool_config.scheduled_agent_updates.schedules)}."
  }
}
