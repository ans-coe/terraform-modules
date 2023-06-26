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

variable "name" {
  description = "The name of the application gateway."
  type        = string
}

variable "enable_http2" {
  description = "Enables HTTP2 on the application gateway."
  type        = bool
  default     = null
}

variable "sku" {
  description = "The SKU details of the application gateway."
  type = object({
    name     = string
    tier     = string
    capacity = optional(number, 1)
  })
  default = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
}

variable "autoscale_configuration" {
  description = "Autoscaling configuration of this application gateway."
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "subnet_id" {
  description = "The subnet ID used to host the application gateway."
  type        = string
}

variable "firewall_policy_id" {
  description = "A firewall policy ID to use with this application gateway."
  type        = string
  default     = null
}

variable "default_waf_policy" {
  description = "Configuration for the default WAF policy."
  type = object({
    enabled           = optional(bool, true)
    name              = optional(string)
    enable_prevention = optional(bool, false)
    enable_bot_rules  = optional(bool, true)
  })
  default = {}
}

variable "public_ip_name" {
  description = "The name of the public IP address if overriding the default."
  type        = string
  default     = null
}

variable "enable_public_frontend" {
  description = "Enable the public frontend on the application gateway."
  type        = bool
  default     = true
}

variable "enable_private_frontend" {
  description = "Enable the private frontend on the application gateway."
  type        = bool
  default     = false
}

variable "private_frontend_ip" {
  description = "The private IP used on the private frontend."
  type        = string
  default     = null
}

variable "private_frontend_subnet_id" {
  description = "The subnet ID used for the private frontend."
  type        = string
  default     = null
}

variable "custom_frontend_ports" {
  description = "A map of names to port numbers to use on the frontend ports if the default Http=80 Https=443 are not sufficient."
  type        = map(number)
  default     = {}
}

variable "ssl_policy" {
  description = "The predefined SSL policy to use with the application gateway."
  type        = string
  default     = "AppGwSslPolicy20220101"
}

variable "identity_ids" {
  description = "Managed identities to use on the application gateway."
  type        = set(string)
  default     = []
}

variable "certificates" {
  description = "Map of name to key vault secret IDs for certificates to add to the application gateway."
  type        = map(string)
  default     = {}
}

variable "backend_address_pools" {
  description = "Maps of objects contianing backend address pool information."
  type = map(object({
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  default = {}
}

variable "basic_backends" {
  description = "Maps of objects containing backends with a basic configuration e.g. direct all traffic to backend."
  type = map(object({
    hostname                 = string
    ssl_certificate_name     = optional(string, "selfsigned")
    http_frontend_port_name  = optional(string, "Http")
    https_frontend_port_name = optional(string, "Https")
    upgrade_connection       = optional(bool, true)
    private_frontend         = optional(bool, false)

    address_pool_name     = optional(string, "default")
    backend_hostname      = optional(string)
    backend_protocol      = optional(string, "Http")
    backend_port          = optional(number, 80)
    cookie_based_affinity = optional(bool, false)

    trusted_root_certificate_data = optional(string)
    probe = optional(object({
      enabled         = optional(bool, true)
      minimum_servers = optional(number)
      path            = optional(string, "/")
      body            = optional(string)
      status_codes    = optional(list(string), ["200-399"])
    }), {})
  }))
  default = {}
}

variable "redirect_backends" {
  description = "Maps of objects containing backends with a redirect configuration e.g. 301 to example.com."
  type = map(object({
    hostname                 = string
    ssl_certificate_name     = optional(string, "selfsigned")
    http_frontend_port_name  = optional(string, "Http")
    https_frontend_port_name = optional(string, "Https")
    upgrade_connection       = optional(bool, false)
    private_frontend         = optional(bool, false)

    url = string
  }))
  default = {}
}
