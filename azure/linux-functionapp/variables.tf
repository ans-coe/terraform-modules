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

variable "application_stack" {
  description = "A map detailing the application stack."
  type        = map(string)
  default = {
    python_version = "3.10"
  }
}

variable "site_config" {
  description = "An object with site config values."
  type = object({
    "always_on"                                     = optional(bool, false)
    "api_management_api_id"                         = optional(string)
    "api_definition_url"                            = optional(string)
    "app_command_line"                              = optional(string)
    "app_scale_limit"                               = optional(number)
    "application_insights_key"                      = optional(string)
    "application_insights_connection_string"        = optional(string)
    "container_registry_use_managed_identity"       = optional(bool)
    "container_registry_managed_identity_client_id" = optional(string)
    "elastic_instance_minimum"                      = optional(number)
    "http2_enabled"                                 = optional(bool)
    "scm_use_main_ip_restriction"                   = optional(bool)
    "load_balancing_mode"                           = optional(string)
    "managed_pipeline_mode"                         = optional(string)
    "pre_warmed_instance_count"                     = optional(number)
    "remote_debugging_enabled"                      = optional(bool)
    "remote_debugging_version"                      = optional(string)
    "runtime_scale_monitoring_enabled"              = optional(bool)
    "scm_type"                                      = optional(string)
    "use_32_bit_worker"                             = optional(bool)
    "websockets_enabled"                            = optional(bool)
    "ftps_state"                                    = optional(string)
    "health_check_path"                             = optional(string)
    "health_check_eviction_time_in_min"             = optional(number)
    "worker_count"                                  = optional(number)
    "minimum_tls_version"                           = optional(string)
    "scm_minimum_tls_version"                       = optional(string)
    "cors"                                          = optional(list)
    "vnet_route_all_enabled"                        = optional(bool)
    "detailed_error_logging_enabled"                = optional(bool)
    "linux_fx_version"                              = optional(string)
  })
  default = {}
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

variable "default_documents" {
  description = "A list of strings for default documents."
  type        = list(string)
  default     = null
}

variable "subnet_id" {
  description = "The subnet to deploy this function app to."
  type        = string
  default     = null
}

variable "create_application_insights" {
  description = "Create an instance of Log Analytics and Application Insights for the function appp."
  type        = bool
  default     = true
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

variable "slots" {
  description = "Names for slots that are clones of the app."
  type        = set(string)
  default     = []
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

variable "public_network_access_enabled" {
  description = "Do you want to enable public access"
  type        = bool
  default     = true
}

