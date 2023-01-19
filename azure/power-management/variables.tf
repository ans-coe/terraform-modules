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
  default     = "power-management-aa"
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
  description = "A list of scheduled hours in 24h format to create for weekdays."
  type        = list(string)
  default     = ["0830", "1800"]

  validation {
    # Run regex on all scheduled hours.
    # Search for "false" in the created list.
    # If 'false' appears, fail the check.
    condition = !can(index([
      for t in var.scheduled_hours
      : can(regex("^\\d{4}$", t))
    ], false))
    error_message = "The scheduled_hours must be in 24h format e.g 0830 or 1800."
  }
}
