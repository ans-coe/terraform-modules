variable "convention" {
  type    = list(string)
  default = ["T", "W", "E", "I"]
  validation {
    condition     = length(var.convention) == length(distinct(var.convention))
    error_message = "Every position in the convention can only be defined once"
  }
}

variable "max_instances" {
  description = "The maximum number of instances outputted"
  type = number
  default = 5
}

variable "delimiter" {
  description = "The character used to seperate the parts of the name"
  type        = string
  default     = "-"
}

variable "environment" {
  description = "Production / Dev / UAT / Staging"
  type        = string
  default     = ""
}
variable "region" {
  description = "The specific region for the resources"
  type        = string
  default     = ""
}
variable "workload" {
  description = "The specific workload for this application"
  type        = string
  default     = ""
}
variable "department" {
  description = "Department Name"
  type        = string
  default     = ""
}

variable "custom1" {
  description = "Custom Name Input - Refereced as C1"
  type        = string
  default     = null
}
variable "custom2" {
  description = "Custom Name Input - Refereced as C2"
  type        = string
  default     = null
}
variable "custom3" {
  description = "Custom Name Input - Refereced as C3"
  type        = string
  default     = null
}
variable "custom4" {
  description = "Custom Name Input - Refereced as C4"
  type        = string
  default     = null
}
variable "custom5" {
  description = "Custom Name Input - Refereced as C5"
  type        = string
  default     = null
}
variable "instance_number_length" {
  description = "If instance numbering is used on a resource, how many characters should this be"
  type        = number
  default     = 2
}

variable "resource_override" {
  description = "Used to override specific resources and add new ones"
  type = map(object({
    dashes = optional(bool)
    regex  = optional(string)
    scope  = optional(string)
    slug   = optional(string)

    length = optional(object({
      max = optional(number)
      min = optional(number)
    }))
  }))
  default = {}
}