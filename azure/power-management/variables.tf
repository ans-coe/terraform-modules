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
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

############
# Automation
############

variable "name" {
  description = "The name of the Power Management Automation Account."
  type        = string
  default     = "aa-pm"
}

variable "custom_role_scope" {
  description = "The scope the custom role created for this automation should be created at. Defaults to the target subscription."
  type        = string
  default     = null
}

variable "managed_subscription_ids" {
  description = "A list of subscription IDs that will be managed by this module."
  type        = list(string)
  default     = []
}

variable "log_verbose" {
  description = "Enable verbose logging."
  type        = bool
  default     = false
}

variable "log_progress" {
  description = "Enable progress logging."
  type        = bool
  default     = false
}

variable "timezone" {
  description = "The timezone used for the created schedules."
  type        = string
  default     = "Etc/UTC"
}

variable "scheduled_hours" {
  description = "A map of schedule names to hours in 24h format to create for weekdays."
  type        = map(string)
  default = {
    "morning" = "0830"
    "evening" = "1800"
  }

  validation {
    # Run regex on all scheduled hours.
    # Search for "false" in the created list.
    # If 'false' appears, fail the check.
    condition = !can(index([
      for k, v in var.scheduled_hours
      : can(regex("^\\d{4}$", v))
    ], false))
    error_message = "The scheduled_hours value must be in 24h format e.g 0830 or 1800."
  }
}
