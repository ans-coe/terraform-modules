## Resource Variables

variable "resource_group_name" {
  description = "The resource group name"
  type        = string
}

variable "location" {
  description = "The location where the Application Gateway will run "
  type        = string
}

variable "name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "subnet_id" {
  description = "Subnet that the Application Gateway will belong to"
  type        = string
}

variable "tags" {
  description = "Resource Tags"
  type        = map(string)
  default     = null
}

variable "sku" {
  description = "Properties relating to the SKU of the Applicaton Gateway"
  type = object({
    capacity     = optional(number, 1)
    max_capacity = optional(number)
  })
  default = {}
  validation {
    condition     = var.sku.max_capacity == null ? true : var.sku.max_capacity > var.sku.capacity
    error_message = "Max capacity must be greater than capacity or not set at all"
  }
}

## Frontend Variables

variable "private_ip" {
  description = "A private IP address for the frontend"
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Set this bool to create a public IP address automatically"
  type        = bool
  default     = true
}

variable "pip_name" {
  description = "Override The Public IP Name"
  type        = string
  default     = null
}

variable "additional_frontend_ports" {
  description = "Map of Additional Frontend Ports"
  type        = map(number)
  default     = {}
}

variable "enable_http2" {
  description = "Enables HTTP2 on the application gateway."
  type        = bool
  default     = null
}

### SSL Variables

variable "ssl_certificates" {
  description = "Map of SSL Certs"
  type = map(object({
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = {}
  validation {
    condition     = alltrue([for c, v in var.ssl_certificates : v.key_vault_secret_id != null ? alltrue([v.data == null, v.password == null]) : true])
    error_message = "For each certificate, if key_vault_secret_id is set, data and password must not be set"
  }
  validation {
    condition     = alltrue([for c, v in var.ssl_certificates : can(regex("^[0-9A-Za-z-_]+$", c))])
    error_message = "SSL Certificate names can contain alphanumeric characters or dash(-) or underscore(_). Underscore gets converted to dash in keyvault"
  }
}

variable "ssl_policy" {
  description = "The predefined SSL policy to use with the application gateway."
  type        = string
  default     = "AppGwSslPolicy20220101"
}

// A key vault can be created automatically, specified or disabled entirely.

variable "use_key_vault" {
  description = "Bool to use a keyvault. If key_vault_id is not set, a key vault will be created"
  type        = bool
  default     = true
}

variable "key_vault_name" {
  description = "Overwrite the name of the keyvault. Value is ignored if use_key_vault is false"
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "Specify the value of the key vault ID to store the SSL certificates. Value is ignored if use_key_vault is false"
  type        = string
  default     = null
}

variable "key_vault_user_assigned_identity_name" {
  description = "Overwrite the name of the umid. Value is ignored if use_key_vault is false"
  type        = string
  default     = null
}

variable "http_listeners" {
  description = "Map of HTTP Listeners"
  type = map(object({
    frontend_ip_configuration_name = optional(string, "public_frontend")
    frontend_port_name             = optional(string, "http")
    https_enabled                  = optional(bool, false)
    host_names                     = optional(list(string), [])
    ssl_certificate_name           = optional(string)
    routing = optional(map(object({
      //Path Based
      path_rules = optional(map(object({
        paths                      = list(string)
        backend_address_pool_name  = string
        backend_http_settings_name = optional(string, "default_settings")
      })))
      redirect_configuration = optional(object({
        redirect_type        = optional(string, "Permanent")
        target_listener_name = optional(string)
        target_url           = optional(string)
        include_path         = optional(bool, true)
        include_query_string = optional(bool, true)
      }))
      backend_address_pool_name  = optional(string)
      backend_http_settings_name = optional(string, "default_settings")
      priority                   = optional(number, 100)
      })),
      {
        default_routing_rule = {
          backend_address_pool_name = "default_backend"
        }
    })
  }))
  default = {
    default_listener = {}
  }

  ## Routing Validation Rules
  validation {
    condition = length(flatten([
      for k, r in var.http_listeners : [
        for k1, v in r.routing : k1
        ]])) == length(distinct(flatten([
        for k, r in var.http_listeners : [
          for k1, v in r.routing : k1
    ]])))
    error_message = "Every routing rule across all listeners must have a unique name."
  }
  validation {
    condition = length(flatten([
      for k, r in var.http_listeners : [
        for k1, v in r.routing : v.priority
        ]])) == length(distinct(flatten([
        for k, r in var.http_listeners : [
          for k1, v in r.routing : v.priority
    ]])))
    error_message = "Every routing rule across all listeners must have a unique priority."
  }
  validation {
    condition = alltrue([
      for k, r in var.http_listeners
      : alltrue([
        for k1, v in r.routing
        : v.redirect_configuration == null ? true : alltrue([v.path_rules == null, v.backend_address_pool_name == null])
      ])
    ])
    error_message = "If redirect_configuration is set, path_rules and backend_address_pool_name must be not set."
  }
  validation {
    condition = alltrue([
      for k, r in var.http_listeners
      : alltrue([
        for k1, v in r.routing
        : v.path_rules == null ? true : v.redirect_configuration == null
      ])
    ])
    error_message = "If path_rules is set, redirect_configuration must not be set."
  }
  validation {
    condition = alltrue([
      for k, r in var.http_listeners
      : alltrue([
        for k1, v in r.routing
        : v.path_rules == null ? true : v.backend_address_pool_name != null
      ])
    ])
    error_message = "If path_rules is set, backend_address_pool_name must be set."
  }
  validation {
    condition = alltrue([
      for k, r in var.http_listeners
      : alltrue([
        for k1, v in r.routing
        : v.backend_address_pool_name == null ? true : v.redirect_configuration == null
      ])
    ])
    error_message = "If backend_address_pool_name is set, redirect_configuration must not be set."
  }
}

## Backend Variables

variable "backend_address_pools" {
  description = "Map of backend address pools"
  type = map(object({
    ip_addresses = optional(list(string))
    fqdns        = optional(list(string))
  }))
}

variable "backend_http_settings" {
  description = "Map of Backend HTTP Settings"
  type = map(object({
    port                           = optional(number, 80)
    https_enabled                  = optional(bool, false)
    cookie_based_affinity          = optional(bool, true)
    affinity_cookie_name           = optional(string, "ApplicationGatewayAffinity")
    probe_name                     = optional(string, "default_probe")
    host_name                      = optional(string)
    request_timeout                = optional(number, 30)
    trusted_root_certificate_names = optional(list(string))
    // pick_host_name_from_backend_address only applies when host_name is null
    pick_host_name_from_backend_address = optional(bool, true)
  }))
  default = {
    default_settings = {}
  }
}

variable "trusted_root_certificates" {
  description = "Map of trusted root certificates to use with the backend."
  type = map(object({
    data                = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = {}

  validation {
    error_message = "One of data or key_vault_secret_id must be specified for each certificate."
    condition = alltrue([
      for certificate in var.trusted_root_certificates
      : anytrue([
        certificate["data"] != null,
        certificate["key_vault_secret_id"] != null,
      ])
    ])
  }
}

variable "probe" {
  description = "Map of Probes"
  type = map(object({
    https_enabled       = optional(bool, false)
    interval            = optional(number, 30)
    path                = optional(string, "/")
    timeout             = optional(number, 30)
    unhealthy_threshold = optional(number, 3)
    port                = optional(number)
    host                = optional(string)
    match = optional(list(object({
      body        = optional(string)
      status_code = optional(list(string))
      })), [{
      status_code = [
        "200-399"
      ]
    }])
  }))
  default = {
    default_probe = {}
  }
}

# WAF Variable

variable "waf_configuration" {
  description = "Rules Defining The WAF"
  type = object({
    policy_name   = string
    firewall_mode = optional(string, "Prevention")

    enable_OWASP           = optional(bool, true)
    OWASP_rule_set_version = optional(string, "3.2")
    OWASP_rule_group_override = optional(map(map(object({
      enabled = optional(bool, true)
      action  = optional(string)
    }))), {})

    enable_Microsoft_BotManagerRuleSet           = optional(bool, false)
    Microsoft_BotManagerRuleSet_rule_set_version = optional(string, "1.0")
    Microsoft_BotManagerRuleSet_rule_group_override = optional(map(map(object({
      enabled = optional(bool, true)
      action  = optional(string)
    }))), {})

    file_upload_limit_mb     = optional(number, 500)
    max_request_body_size_kb = optional(number, 128)
    managed_rule_exclusion = optional(list(object({
      match_variable          = string
      selector_match_operator = optional(string)
      selector                = optional(string)
    })), [])
    custom_rules = optional(map(object({
      priority = number
      action   = optional(string, "Block")
      match_conditions = list(object({
        match_values       = list(string)
        operator           = optional(string, "Contains")
        negation_condition = optional(bool, true)
        transforms         = optional(list(string))

        match_variables = optional(list(object({
          variable_name = string
          selector      = optional(string)
        })), [{ variable_name = "RemoteAddr" }])
      }))
    })), {})
  })
  default = null
}