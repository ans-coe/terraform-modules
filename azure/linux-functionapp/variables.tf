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

##############
# App Service
##############

variable "name" {
  description = "The name of the function app."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the function app's backing storage account."
  type        = string
  default     = null
}

variable "plan" {
  description = "Object detailing the plan, if creating one with this module."
  type = object({
    create         = optional(bool, true)
    id             = optional(string)
    name           = optional(string)
    sku_name       = optional(string, "Y1")
    zone_balancing = optional(bool, false)
  })
  default = {}
}

variable "subnet_id" {
  description = "The subnet to deploy this function app to."
  type        = string
  default     = null
}

variable "daily_memory_time_quota_gs" {
  description = "Daily memory time quota in gigabyte-seconds."
  type        = string
  default     = null
}

variable "functions_extension_version" {
  description = "Functions extension version to use on this function app."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "A map of app settings."
  type        = map(string)
  default     = {}
}

variable "site_config" {
  description = "A map with site config values."
  type        = map(any)
  default     = {}
}

variable "cors" {
  description = "Cross origin resource sharing configuration."
  type = object({
    allowed_origins     = list(string)
    support_credentials = optional(bool, null)
  })
  default = null
}

variable "application_stack" {
  description = "A map detailing the application stack."
  type        = map(string)
  default = {
    python_version = "3.10"
  }
}

variable "identity_ids" {
  description = "A list of user identity IDs to use for the function app."
  type        = list(string)
  default     = []
}

variable "key_vault_identity_id" {
  description = "The user managed identity used for key vault."
  type        = string
  default     = null
}

variable "allowed_ips" {
  description = "A list of allowed CIDR ranges."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "A list of allowed subnet IDs."
  type        = list(string)
  default     = []
}

variable "allowed_service_tags" {
  description = "A list of allowed service tags."
  type        = list(string)
  default     = []
}

variable "allowed_frontdoor_ids" {
  description = "A list of allowed frontdoor IDs."
  type        = list(string)
  default     = []
}

variable "allowed_scm_ips" {
  description = "A list of SCM allowed CIDR ranges."
  type        = list(string)
  default     = []
}

variable "allowed_scm_subnet_ids" {
  description = "A list of SCM allowed subnet IDs."
  type        = list(string)
  default     = []
}

variable "allowed_scm_service_tags" {
  description = "A list of SCM allowed service tags."
  type        = list(string)
  default     = []
}

variable "connection_strings" {
  description = "A list of connection string objects."
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}
