variable "sku" {
  description = "Properties relating to the SKU of the Applicaton Gateway"
  type = object({
    name     = string
    tier     = string
    capacity = optional(string, null)
  })
  default = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
}

variable "autoscale" {
  description = "Properties relating to the Autoscalling of the Applicaton Gateway"
  type = object({
    min = string
    max = string
  })
  default = {
    max = "3"
    min = "1"
  }
}

variable "create_resource_group" {
  description = "Boolean to defined whether to create the resource group or not"
  type        = bool
  default     = false
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
    name                  = string
    port                  = optional(number, 80)
    protocol              = optional(string, "Http")
    cookie_based_affinity = optional(string, "Enabled")
    probe_name            = optional(string, "Default")
  }))
  default = [{
    name = "Default"
  }]
}

variable "frontend_ip_configurations" {
  description = "List of Frontend IP Configurations"
  type = list(object({
    name                 = string
    private_ip_address   = optional(string, null)
    public_ip_address_id = optional(string, null)
  }))
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
    frontend_ip_configuration_name = string
    frontend_port_name             = optional(string, "Http")
    protocol                       = optional(string, "Http")
    host_name                      = optional(string, null)
    host_names                     = optional(list(string), null)
    ssl_certificate_name           = optional(string, null)
  }))
}
variable "ssl_certificates" {
  description = "List of SSL Certs"
  type = list(object({
    name                = string
    data                = optional(string, null)
    password            = optional(string, null)
    key_vault_secret_id = optional(string, null)
  }))
  default = null
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
  default = null
}
variable "request_routing_rules" {
  description = "List of Routing Rules"
  type = list(object({
    name                       = string
    rule_type                  = optional(string, "PathBasedRouting")
    http_listener_name         = string
    backend_address_pool_name  = optional(string, null)
    backend_http_settings_name = optional(string, null)
    url_path_map_name          = optional(string, null)
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
    host                                      = optional(string, null)
  }))
  default = [{
    name = "Default"
  }]
}