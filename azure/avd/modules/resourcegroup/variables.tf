variable "name" {
  description = "The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created."
  type        = string
}

variable "location" {
  description = "Azure region to use"
  type        = string
}

variable "lock_level" {
  description = "Specifies the Level to be used for this RG Lock. Possible values are Empty (no lock), CanNotDelete and ReadOnly."
  type        = string
  default     = ""

  validation {
    condition     = try(contains(["", "CanNotDelete", "ReadOnly"], var.lock_level), true)
    error_message = "The `lock_level` value must be valid. Possible values are Empty (no lock), CanNotDelete and ReadOnly"
  }
}
