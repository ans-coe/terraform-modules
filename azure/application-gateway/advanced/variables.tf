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
    name         = string
    tier         = string
    capacity     = optional(number, 1)
    max_capacity = optional(number, 1)
  })
  default = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
  validation {
    condition     = var.sku.max_capacity >= var.sku.capacity
    error_message = "Max capacity must be greater than or equal to capacity"
  }
}

variable "identity_ids" {
  description = "Map of potential UserAssigned identities"
  type        = list(string)
  default     = null
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

variable "ssl_certificates" {
  description = "Map of SSL Certs"
  type = map(object({
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = {}
  validation {
    condition     = try(alltrue([for c, v in var.ssl_certificates : (v.key_vault_secret_id != null || (v.data != null && v.password != null))]), true)
    error_message = "Each certificate must specify either data and password or key_vault_secret_id."
  }
}

variable "ssl_policy" {
  description = "The predefined SSL policy to use with the application gateway."
  type        = string
  default     = "AppGwSslPolicy20220101"
}

variable "http_listeners" {
  description = "Map of HTTP Listeners"
  type = map(object({
    frontend_ip_configuration_name = optional(string, "public_frontend")
    frontend_port_name             = optional(string, "Http")
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
    port                                = optional(number, 80)
    https_enabled                       = optional(bool, false)
    cookie_based_affinity               = optional(bool, true)
    affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")
    probe_name                          = optional(string, "default_probe")
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, true)
    request_timeout                     = optional(number, 30)
    trusted_root_certificate_names      = optional(list(string))
  }))
  default = {
    default_settings = {}
  }
}

variable "trusted_root_certificate" {
  description = "Map of SSL Certs"
  type        = map(string)
  default     = {}
}

variable "probe" {
  description = "Map of Probes"
  type = map(object({
    https_enabled                             = optional(bool, false)
    interval                                  = optional(number, 30)
    path                                      = optional(string, "/")
    timeout                                   = optional(number, 30)
    unhealthy_threshold                       = optional(number, 3)
    port                                      = optional(number, 80)
    pick_host_name_from_backend_http_settings = optional(bool, false)
    host                                      = optional(string)
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
    policy_name              = string
    firewall_mode            = optional(string, "Prevention")
    rule_set_type            = optional(string, "OWASP")
    rule_set_version         = optional(string, "3.2")
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