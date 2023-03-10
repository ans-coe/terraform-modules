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
  description = "The name of the app service."
  type        = string
}

variable "plan" {
  description = "Object detailing the plan, if creating one with this module."
  type = object({
    create         = optional(bool, true)
    id             = optional(string)
    name           = optional(string)
    sku_name       = optional(string, "B1")
    zone_balancing = optional(bool, false)
  })
  default = {}
}

variable "zip_deploy_file" {
  description = "Path to a zip file to deploy to the app service."
  type        = string
  default     = null
}

variable "application_stack" {
  description = "A map detailing the application stack."
  type        = map(string)
  default = {
    docker_image     = "mcr.microsoft.com/appsvc/staticsite"
    docker_image_tag = "latest"
  }
}

variable "site_config" {
  description = "A map with site config values."
  type        = map(any)
  default     = {}
}

variable "app_settings" {
  description = "A map of app settings."
  type        = map(string)
  default     = {}
}

variable "sticky_app_settings" {
  description = "A list of sticky app_setting values."
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

variable "sticky_connection_strings" {
  description = "A list of sticky connection_strings values."
  type        = list(string)
  default     = []
}

variable "cors" {
  description = "Cross origin resource sharing configuration."
  type = object({
    allowed_origins     = list(string)
    support_credentials = optional(bool, null)
  })
  default = null
}

variable "subnet_id" {
  description = "The subnet to deploy this app service to."
  type        = string
  default     = null
}

variable "log_level" {
  description = "The log level to use with this app service."
  type        = string
  default     = "Error"

  validation {
    condition     = contains(["Off", "Error", "Warning", "Information", "Verbose"], var.log_level)
    error_message = "Variable 'log_level' must be one of 'Off', 'Error', 'Warning', 'Information', 'Verbose'."
  }
}

variable "log_config" {
  description = "The log configuration to use with this app service."
  type = object({
    detailed_error_messages = optional(bool, false)
    failed_request_tracing  = optional(bool, false)
    retention_in_days       = optional(number, 7)
    storage_account_name    = optional(string)
    storage_account_rg      = optional(string)
  })
  default = {
    detailed_error_messages = false
    failed_request_tracing  = false
    retention_in_days       = 7
  }
}

variable "identity_ids" {
  description = "A list of user identity IDs to use for the app service."
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
