variable "name" {
  description = "The vnet name of the hub"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
}

variable "location" {
  description = "The location of created resources."
  type        = string
  default     = "uksouth"
}

variable "fetch_nsg" {
  description = "Should this module get information on NSGs"
  type        = bool
  default     = true
}

variable "fetch_rt" {
  description = "Should this module get information on Routing Tables"
  type        = bool
  default     = true
}