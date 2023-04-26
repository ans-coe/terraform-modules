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
}

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

variable "backend_address_pools" {
  description = "List of backend address pools"
  type = list(object({
    name         = string
    ip_addresses = optional(list(string))
    fqdns        = optional(list(string))
  }))
}

variable "backend_http_settings" {
  description = "List of Backend HTTP Settings"
  type = list(object({
    name                                = string
    port                                = optional(number, 80)
    protocol                            = optional(string, "Http")
    cookie_based_affinity               = optional(bool, true)
    affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")
    probe_name                          = optional(string, "Default")
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, true)
    request_timeout                     = optional(number, 30)
    trusted_root_certificate_names      = optional(list(string))
  }))
  default = [{
    name = "Default"
  }]
}
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

variable "http_listeners" {
  description = "List of HTTP Listeners"
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = optional(string, "PublicFrontend")
    frontend_port_name             = optional(string, "Http")
    protocol                       = optional(string, "Http")
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    ssl_certificate_name           = optional(string)
  }))
  default = [{
    name = "Default"
  }]
}
variable "ssl_certificates" {
  description = "List of SSL Certs"
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
  validation {
    condition     = try(alltrue([for cert in var.ssl_certificates : (cert.key_vault_secret_id != null || (cert.data != null && cert.password != null))]), true)
    error_message = "Each certificate must specify either data and password or key_vault_secret_id."
  }
}

variable "trusted_root_certificate" {
  description = "List of SSL Certs"
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "url_path_maps" {
  description = "List of Path Maps"
  type = list(object({
    name                               = string
    default_backend_address_pool_name  = string
    default_backend_http_settings_name = optional(string, "Default")
    path_rule = list(object({
      name                       = string
      paths                      = list(string)
      backend_address_pool_name  = string
      backend_http_settings_name = optional(string, "Default")
    }))
  }))
  default = []
}
variable "request_routing_rules" {
  description = "List of Routing Rules"
  type = list(object({
    name                        = string
    rule_type                   = optional(string, "PathBasedRouting")
    http_listener_name          = string
    backend_address_pool_name   = optional(string, "Default")
    backend_http_settings_name  = optional(string)
    url_path_map_name           = optional(string)
    priority                    = optional(number, 100)
    redirect_configuration_name = optional(string)
  }))
}

variable "redirect_configurations" {
  description = "List of Redirection Configurations"
  type = list(object({
    name                 = string
    redirect_type        = optional(string, "Permanent")
    target_listener_name = optional(string)
    target_url           = optional(string)
    include_path         = optional(bool, true)
    include_query_string = optional(bool, true)
  }))
  default = []
}

variable "identity_ids" {
  description = "List of potential UserAssigned identities"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Resource Tags"
  type        = map(string)
  default     = null
}

variable "probe" {
  description = "List of Probes"
  type = list(object({
    name                                      = optional(string, "Default")
    protocol                                  = optional(string, "Http")
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
  default = [{
    name = "Default"
  }]
}

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
    custom_rules = optional(list(object({
      name     = string
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
    })), [])
  })
  default = null
}

variable "ssl_policy" {
  description = "The predefined SSL policy to use with the application gateway."
  type        = string
  default     = "AppGwSslPolicy20220101"
}