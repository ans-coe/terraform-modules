variable "sku" {
  description = "Properties relating to the SKU of the Applicaton Gateway"
  type = object({
    name     = string
    tier     = string
    capacity = optional(string)
  })
  default = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
}

variable "autoscale" {
  description = "Properties relating to the Autoscalling of the Applicaton Gateway"
  type = object({
    min = optional(number, 1)
    max = optional(number, 3)
  })
  default = {}
}

variable "resource_group_name" {
  description = "The resource group name"
  type        = string
}

variable "location" {
  description = "The location where the Application Gateway will run "
  type        = string
}

variable "application_gateway_name" {
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
    ip_addresses = list(string)
  }))
}

variable "backend_http_settings" {
  description = "List of Backend HTTP Settings"
  type = list(object({
    name                                = string
    port                                = optional(number, 80)
    protocol                            = optional(string, "Http")
    cookie_based_affinity               = optional(string, "Enabled")
    probe_name                          = optional(string, "Default")
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, true)
    request_timeout                     = optional(number, 30)
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
variable "frontend_ports" {
  description = "List of Frontend Ports"
  type = list(object({
    name = string
    port = number
  }))
  default = [{
    name = "Http"
    port = 80
    }, {
    name = "Https"
    port = 443
  }]
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
    name                       = string
    rule_type                  = optional(string, "PathBasedRouting")
    http_listener_name         = string
    backend_address_pool_name  = optional(string)
    backend_http_settings_name = optional(string)
    url_path_map_name          = optional(string)
    priority                   = optional(number, 100)
  }))
}

variable "identity_ids" {
  description = "List of potential UserAssigned identities"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Resource Tags"
  type        = map(string)
}

variable "probe" {
  description = "List of Routing Rules"
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