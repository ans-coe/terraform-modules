###################
# Global Variables
###################

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

##########
# Network
##########

variable "virtual_network_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address range for the virtual network."
  type        = list(string)

  validation {
    error_message = "Must be valid IPv4 CIDR."
    condition     = can(cidrhost(one(var.address_space[*]), 0))
  }
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

  validation {
    error_message = "extra_subnets.prefix values must be valid IPv4 CIDR values."
    condition     = alltrue([for k, v in var.extra_subnets : can(cidrhost(v.prefix, 0))])
  }
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

  validation {
    error_message = "private_endpoint_subnet.subnet_prefix must be a valid IPv4 CIDR."
    condition = var.private_endpoint_subnet == null || can(cidrhost(var.private_endpoint_subnet.subnet_prefix, 0)
    )
  }

  validation {
    error_message = "Valid values for service_endpoints are: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage or Microsoft.Web."
    condition     = var.private_endpoint_subnet == null || can(contains(["Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"], var.private_endpoint_subnet.service_endpoints))
  }
}

###########
# Firewall
###########

variable "firewall_config" {
  description = "Configuration for the firewall if enabled."
  type = object({
    name               = string
    subnet_prefix      = string
    public_ip_name     = optional(string)
    sku_tier           = optional(string, "Standard")
    route_table_name   = optional(string)
    default_route_name = optional(string, "default")
    firewall_policy_id = optional(string)
  })
  default = null

  validation {
    error_message = "firewall_config.subnet_prefix must be a valid IPv4 CIDR."
    condition = var.firewall_config == null || can(cidrhost(var.firewall_config.subnet_prefix, 0)
    )
  }
  validation {
    error_message = "Firewall SKU can be either Basic, Standard or Premium."
    condition     = var.firewall_config == null || can(contains(["Basic", "Standard", "Premium"], var.firewall_config.sku_tier))
  }
}

##########
# Bastion
##########

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

  validation {
    error_message = "bastion_config.subnet_prefix must be valid a IPv4 CIDR."
    condition = var.bastion_config == null || can(cidrhost(var.bastion_config.subnet_prefix, 0)
    )
  }
}

##########################
# Virtual Network Gateway
##########################

variable "virtual_network_gateway_config" {
  description = "Configuration for virtual network gateway if enabled."
  type = object({
    name           = string
    subnet_prefix  = string
    public_ip_name = optional(string)
    generation     = optional(string, "Generation1")
    sku            = optional(string, "VpnGw1")
    type           = optional(string, "Vpn")
    vpn_type       = optional(string, "RouteBased")
  })
  default = null

  validation {
    error_message = "virtual_network_gateway_config.subnet_prefix must be a valid IPv4 CIDR."
    condition     = var.virtual_network_gateway_config == null || can(cidrhost(var.virtual_network_gateway_config.subnet_prefix, 0))
  }

  validation {
    error_message = "The Virtual Network Gateway Generation can be either Generation1, Generation2 or None."
    condition     = var.virtual_network_gateway_config == null || can(contains(["Generation1", "Generation2", "None"], var.virtual_network_gateway_config.generation))
  }

  validation {
    error_message = "The Virtual Network Gateway Generation can be either Basic, VpnGw1, VpnGw2, VpnGw3, VpnGw4, VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ, VpnGw4AZ, or VpnGw5AZ."
    condition     = var.virtual_network_gateway_config == null || can(contains(["Basic", "VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5", "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ"], var.virtual_network_gateway_config.sku))
  }

  validation {
    error_message = "If the sku is set to Basic, VpnGw1 or VpnGw1AZ, then generation must be set to Generation1."
    condition     = contains(["Basic", "VpnGw1", "VpnGw1AZ"], try(var.virtual_network_gateway_config.sku, [])) ? var.virtual_network_gateway_config.generation == "Generation1" : true
  }

  validation {
    error_message = "The values for type are either Vpn or ExpressRoute."
    condition     = var.virtual_network_gateway_config == null || can(contains(["Vpn", "ExpressRoute"], var.virtual_network_gateway_config.type))
  }

  validation {
    error_message = "The values for vpn_type are either RouteBased or PolicyBased."
    condition     = var.virtual_network_gateway_config == null || can(contains(["RouteBased", "PolicyBased"], var.virtual_network_gateway_config.vpn_type))
  }
}

###################
# Private Resolver
###################

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

  validation {
    error_message = "private_resolver_config.inbound_subnet_prefix must be a valid IPv4 CIDR."
    condition     = var.private_resolver_config == null || can(cidrhost(var.private_resolver_config.inbound_subnet_prefix, 0))
  }

  validation {
    error_message = "private_resolver_config.outbound_subnet_prefix must be a valid IPv4 CIDR."
    condition     = var.private_resolver_config == null || can(cidrhost(var.private_resolver_config.outbound_subnet_prefix, 0))
  }
}

##################
# Network Watcher
##################

variable "create_network_watcher" {
  description = "Enables Network Watcher for the region & subscription."
  type        = bool
  default     = true
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher"
  type        = string
  default     = null
}

variable "network_watcher_resource_group" {
  description = "Name of the Network Watcher Resourece Group"
  type        = string
  default     = null
}


##############
# Private DNS
##############

variable "private_dns_domains" {
  description = "A set of private domains to configure."
  type        = list(string)
  default     = []
}

#######################
# Private Endpoint DNS 
#######################

variable "create_private_endpoint_private_dns_zones" {
  description = "Add the list of private endpoint private dns zones to the list of private dns zones to create."
  type = bool
  default = false
}

##########################
# Log Analytics Workspace
##########################

variable "log_analytics_workspace_id" {
  description = "Log analytics workspace ID to forward diagnostics to."
  type        = string
  default     = null
}
