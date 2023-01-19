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

##############
# App Service
##############

variable "name" {
  description = "The name of the Azure App Service."
  type        = string
}

variable "plan_id" {
  description = "The ID of the app service plan, if using an existing one."
  type        = string
  default     = null
}

variable "plan" {
  description = "Object detailing the plan, if creating one with this module."
  type = object({
    name           = string
    sku_name       = optional(string, "B1")
    zone_balancing = optional(bool, false)
  })
  default = null
}

variable "zip_deploy_file" {
  description = "Path to a zip file to deploy to the webapp."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "Map of app settings."
  type        = map(string)
  default     = {}
}

variable "site_config" {
  description = "Map with site config values."
  type        = map(any)
  default     = {}
}

variable "application_stack" {
  description = "Map detailing the application stack."
  type        = map(string)
  default = {
    docker_image     = "mcr.microsoft.com/appsvc/staticsite"
    docker_image_tag = "latest"
  }
}

variable "identity_ids" {
  description = "A list of user identity IDs to use for the app service."
  type        = list(string)
  default     = null
}

variable "key_vault_identity_id" {
  description = "The user managed identity used for Key Vault."
  type        = string
  default     = null
}

variable "allowed_ips" {
  description = "List of allowed CIDR ranges."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs."
  type        = list(string)
  default     = []
}

variable "allowed_service_tags" {
  description = "List of allowed service tags."
  type        = list(string)
  default     = []
}

variable "allowed_frontdoor_ids" {
  description = "List of allowed frontdoor IDs."
  type        = list(string)
  default     = []
}

variable "allowed_scm_ips" {
  description = "List of SCM allowed CIDR ranges."
  type        = list(string)
  default     = []
}

variable "allowed_scm_subnet_ids" {
  description = "List of SCM allowed subnet IDs."
  type        = list(string)
  default     = []
}

variable "allowed_scm_service_tags" {
  description = "List of SCM allowed service tags."
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

variable "log_level" {
  description = "Log level."
  type        = string
  default     = "Error"

  validation {
    condition     = contains(["Off", "Error", "Warning", "Information", "Verbose"], var.log_level)
    error_message = "Variable 'log_level' must be one of 'Off', 'Error', 'Warning', 'Information', 'Verbose'."
  }
}

variable "log_config" {
  description = "Log configuration."
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

variable "subnet_id" {
  description = "The subnet to deploy this app service to."
  type        = string
  default     = null
}
