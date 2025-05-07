variable "avd_scaling_plan_name" {
  description = "value"
  type        = string
}

variable "hostpool_id" {
  description = "The ID of the HostPool to assign the Scaling Plan to"
  type        = string
}

variable "scaling_plan_config" {
  description = "AVD Scaling Plan specific configuration."
  type = object({
    enabled       = optional(bool, false)
    friendly_name = optional(string)
    description   = optional(string)
    exclusion_tag = optional(string)
    timezone      = optional(string, "UTC") # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
    schedules = optional(list(object({
      name                                 = string
      days_of_week                         = list(string)
      peak_start_time                      = string
      peak_load_balancing_algorithm        = optional(string, "BreadthFirst")
      off_peak_start_time                  = string
      off_peak_load_balancing_algorithm    = optional(string, "DepthFirst")
      ramp_up_start_time                   = string
      ramp_up_load_balancing_algorithm     = optional(string, "BreadthFirst")
      ramp_up_capacity_threshold_percent   = optional(number, 75)
      ramp_up_minimum_hosts_percent        = optional(number, 33)
      ramp_down_start_time                 = string
      ramp_down_capacity_threshold_percent = optional(number, 5)
      ramp_down_force_logoff_users         = optional(string, false)
      ramp_down_load_balancing_algorithm   = optional(string, "DepthFirst")
      ramp_down_minimum_hosts_percent      = optional(number, 33)
      ramp_down_notification_message       = optional(string, "Please log off in the next 45 minutes...")
      ramp_down_stop_hosts_when            = optional(string, "ZeroSessions")
      ramp_down_wait_time_minutes          = optional(number, 45)
    })), [])
    role_assignment = optional(object({
      enabled   = optional(bool, false)
      object_id = optional(string)
    }), {})
    extra_tags = optional(map(string))
  })
  default  = {}
  nullable = false
}
