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

variable "os_type" {
  description = "Windows or Linux Web App"
  type        = string

  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "OS Type must be Windows or Linux"
  }
}

variable "zip_deploy_file" {
  description = "Path to a zip file to deploy to the app service."
  type        = string
  default     = null
}

variable "application_stack" {
  description = "An object detailing the application stack."
  type = object({
    docker_image_name        = optional(string)
    docker_registry_url      = optional(string)
    docker_registry_username = optional(string)
    docker_registry_password = optional(string)
    dotnet_version           = optional(string)
    java_version             = optional(string)
    node_version             = optional(string)
    php_version              = optional(string)

    ## Windows Only
    current_stack                = optional(string)
    dotnet_core_version          = optional(string)
    tomcat_version               = optional(string)
    java_embedded_server_enabled = optional(bool)
    python                       = optional(bool)

    ## Linux Only
    go_version          = optional(string)
    java_server         = optional(string)
    java_server_version = optional(string)
    python_version      = optional(string)
    ruby_version        = optional(string)
  })
  default = {
    docker_image_name   = "azure-app-service/samples/aspnethelloworld:latest"
    docker_registry_url = "https://mcr.microsoft.com"
  }
}

variable "virtual_application" {
  description = "Virtual application configuration for the app service."
  type = set(object({
    virtual_path  = string
    physical_path = string
    preload       = optional(bool, false)
    virtual_directories = optional(list(object({
      physical_path = string
      virtual_path  = string
    })), [])
  }))
  default = null
}

### TO-DO: Add auto_heal_enabled if auto_heal_setting is defined 

variable "site_config" {
  description = "An object with site config values."
  type = object({
    always_on                                     = optional(bool, false)
    api_definition_url                            = optional(string)
    api_management_api_id                         = optional(string)
    app_command_line                              = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool, true)
    default_documents                             = optional(list(string))
    health_check_eviction_time_in_min             = optional(number, 2)
    ftps_state                                    = optional(string)
    health_check_path                             = optional(string)
    http2_enabled                                 = optional(bool, false)
    load_balancing_mode                           = optional(string)
    local_mysql_enabled                           = optional(bool)
    managed_pipeline_mode                         = optional(string)
    minimum_tls_version                           = optional(string, "1.2")
    scm_minimum_tls_version                       = optional(string, "1.2")
    scm_use_main_ip_restriction                   = optional(bool)
    remote_debugging_enabled                      = optional(bool, false)
    remote_debugging_version                      = optional(string)
    use_32_bit_worker                             = optional(bool)
    vnet_route_all_enabled                        = optional(bool)
    websockets_enabled                            = optional(bool, false)
    worker_count                                  = optional(number, 1)
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

  validation {
    error_message = "Type must be a valid value"
    condition = alltrue([for v in var.connection_strings : contains(
      [
        "APIHub",
        "Custom",
        "DocDb",
        "EventHub",
        "MySQL",
        "NotificationHub",
        "PostgreSQL",
        "RedisCache",
        "ServiceBus",
        "SQLAzure",
        "SQLServer"
      ], v.type
    )])
  }
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

variable "logs" {
  description = "The log configuration to use with this app service."
  type = object({
    level                   = optional(string, "Warning")
    detailed_error_messages = optional(bool, false)
    failed_request_tracing  = optional(bool, false)
    retention_in_days       = optional(number, 7)
    retention_in_mb         = optional(number, 100)
  })
  default = {}
}

variable "create_application_insights" {
  description = "Create an instance of Log Analytics and Application Insights for the app service."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Do you want to enable public access"
  type        = bool
  default     = true
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

variable "custom_domain" {
  description = "The custom domain name for the app service"
  type        = string
  default     = null
}

variable "cert_options" {
  description = "Options related to the certificate"
  type = object({
    pfx_blob = optional(string)
    password = optional(string)
    // Setting Keyvault to empty map will cause the creation of Keyvault with default name and example cert
    key_vault = optional(object({
      certificate_name      = string           // Use this value to set the name of the certificate
      key_vault_custom_name = optional(string) // If you wanted to name the keyvault something different to the default.
      key_vault_secret_id   = optional(string) // If the cert already exists, it can be provided here
    }))
  })
  default = null

  validation {
    error_message = "certificate_name = 1-127 character string, starting with a letter and containing only 0-9, a-z, A-Z, and -"
    condition = (
      var.cert_options != null ?
      try(var.cert_options.key_vault != null, false) ?
      length(regexall("^[0-9a-zA-Z-]{1,127}$", var.cert_options.key_vault.certificate_name)) > 0
      : true
      : true
    )
  }

  validation {
    error_message = "key_vault_custom_name = 1-24 character string, starting with a letter and containing only 0-9, a-z, A-Z, and -"
    condition = (
      var.cert_options != null ?
      try(var.cert_options.key_vault != null, false) ?
      var.cert_options.key_vault.key_vault_custom_name != null ? length(regexall("^[0-9a-zA-Z-]{1,24}$", var.cert_options.key_vault.key_vault_custom_name)) > 0 : true
      : true
      : true
    )
  }

  validation {
    error_message = "If key_vault_secret_id is set key_vault_custom_name is ignored so should be null because a keyvault is not created."
    condition = (
      var.cert_options != null ?
      try(var.cert_options.key_vault != null, false) ?
      anytrue([
        (var.cert_options.key_vault.key_vault_secret_id != null) != (var.cert_options.key_vault.key_vault_custom_name != null), // neither can be set at the same time
        (var.cert_options.key_vault.key_vault_secret_id == null) && (var.cert_options.key_vault.key_vault_custom_name == null)  // both can be null
      ])
      : true
      : true
    )
  }
}

variable "identity_options" {
  description = "Options relating to the UMID of the App Service"
  type = object({
    // If use_umid is true but a custom name nor an ID is specified, a UMID will be created with default naming.
    use_umid         = optional(bool, true)
    umid_custom_name = optional(string)
    umid_id          = optional(string) // If a UMID already exists, you can specify it here
  })
  default = {}
  validation {
    error_message = "umid_custom_name and umid_id cannot be set at the same time"
    condition = (
      anytrue([
        (var.identity_options.umid_custom_name != null) != (var.identity_options.umid_id != null), // neither can be set at the same time
        (var.identity_options.umid_custom_name == null) && (var.identity_options.umid_id == null)  // both can be null
      ])
    )
  }
}

variable "autoscaling" {
  description = "Basic implementation of a CPU autoscaler"
  type = object({
    capacity = optional(object({
      minimum = optional(number, 1)
      maximum = optional(number, 3)
      default = optional(number, 1)
    }), {})
    cpu_greater_than = optional(number, 50) // CPU percentage to scale up on
    cpu_less_than    = optional(number, 15) // CPU percentage to scale down on
  })
  default = null
}