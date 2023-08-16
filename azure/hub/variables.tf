variable "resource_group_name" {
  description = "Name of the resource group created for the hub."
  type        = string
}

variable "location" {
  description = "Location to deploy to."
  type        = string
}

variable "tags" {
  description = "Tags to append to resources."
  type        = map(string)
  default     = {}
}

variable "virtual_network_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address range for the virtual network."
  type        = list(string)
}

variable "extra_subnets" {
  description = "Miscelaneous additional subnets to add."
  type = map(object({
    prefix                                        = string
    service_endpoints                             = optional(list(string))
    private_endpoint_network_policies_enabled     = optional(bool)
    private_link_service_network_policies_enabled = optional(bool)
    delegations = optional(map(
      object({
        service = string
        actions = list(string)
      })
    ), {})
  }))
  default = {}
}

variable "private_endpoint_subnet" {
  description = "Configuration for the Private Endpoint subnet."
  type = object({
    subnet_name   = optional(string, "snet-pe")
    subnet_prefix = string
    service_endpoints = optional(list(string), [
      "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB",
      "Microsoft.ContainerRegistry", "Microsoft.EventHub",
      "Microsoft.KeyVault", "Microsoft.ServiceBus",
      "Microsoft.Sql", "Microsoft.Storage",
      "Microsoft.Web"
    ])
  })
  default = null
}

variable "firewall_config" {
  description = "Configuration for the firewall if enabled."
  type = object({
    name             = string
    subnet_prefix    = string
    public_ip_name   = optional(string)
    sku_tier         = optional(string, "Standard")
    route_table_name = optional(string)
  })
  default = null
}

variable "bastion_config" {
  description = "Configuration for the bastion if enabled."
  type = object({
    name                        = string
    resource_group_name         = optional(string)
    subnet_prefix               = string
    public_ip_name              = optional(string)
    network_security_group_name = optional(string)
    whitelist_cidrs             = optional(list(string), ["Internet"])
  })
  default = null
}

variable "virtual_network_gateway_config" {
  description = "Configuration for virtual network gateway if enabled."
  type = object({
    name           = string
    subnet_prefix  = string
    public_ip_name = optional(string)
    sku            = optional(string, "VpnGw1")
  })
  default = null
}

variable "private_resolver_config" {
  description = "Configuration for virtual network gateway if enabled."
  type = object({
    name                   = string
    inbound_endpoint_name  = optional(string)
    inbound_subnet_name    = optional(string, "snet-dnspr-in")
    inbound_subnet_prefix  = string
    outbound_endpoint_name = optional(string)
    outbound_subnet_name   = optional(string, "snet-dnspr-out")
    outbound_subnet_prefix = string
  })
  default = null
}

variable "spoke_networks" {
  description = "Maps of network name to network ID."
  type        = map(string)
  default     = {}
}

variable "private_dns_domains" {
  description = "A set of private domains to configure."
  type        = set(string)
  default     = []
}

variable "network_watcher_config" {
  description = "Configuration for the network watcher resource."
  type = object({
    name                = optional(string)
    resource_group_name = optional(string)
  })
  default = null
}

variable "log_analytics_workspace_id" {
  description = "Log analytics workspace ID to forward diagnostics to."
  type        = string
  default     = null
}
