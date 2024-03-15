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

variable "dns_servers" {
  description = "The DNS servers to use with this virtual network."
  type        = list(string)
  default     = []

  validation {
    error_message = "Values for dns_servers must be valid IPv4 addresses."
    condition     = alltrue([for v in var.dns_servers : can(cidrhost("${v}/32", 0))])
  }
}

variable "include_azure_dns" {
  description = "If using custom DNS servers, include Azure DNS IP as a DNS server."
  type        = bool
  default     = false
}

variable "disable_bgp_route_propagation" {
  description = "Disable Route Propagation. True = Disabled"
  type        = bool
  default     = true
}

variable "ddos_protection_plan_id" {
  description = "A DDoS Protection plan ID to assign to the virtual network."
  type        = string
  default     = null
}

variable "bgp_community" {
  description = "The BGP Community for this virtual network."
  type        = string
  default     = null
}

variable "subnets" {
  description = "Subnets to create in this virtual network with the map name indicating the subnet name."
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string))
    private_endpoint_network_policies_enabled     = optional(bool)
    private_link_service_network_policies_enabled = optional(bool)
    delegations = optional(map(
      object({
        service = string
        actions = list(string)
      })
    ), {})
    associate_default_route_table            = optional(bool, true)
    associate_default_network_security_group = optional(bool, true)
  }))
  default = {}

  validation {
    error_message = "Values for address_prefixes must be valid IPv4 CIDR."
    condition     = alltrue(flatten([for v in var.subnets : [for a in v.address_prefixes : can(cidrhost(a, 0))]]))
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
    zone_redundant     = optional(bool, true)
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

#########################
# Network Security Group
#########################

variable "create_default_network_security_group" {
  description = "Create a Network Security Group to associate with all subnets."
  type        = bool
  default     = true
}

variable "network_security_group_name" {
  description = "Name of the default Network Security Group"
  type        = string
  default     = "default-nsg"
}

variable "nsg_rules_inbound" {
  description = "A list of objects describing a rule inbound."
  type = list(object({
    rule        = optional(string)
    name        = string
    description = optional(string, "Created by Terraform.")

    access   = optional(string, "Allow")
    priority = optional(number)

    protocol = optional(string, "*")
    ports    = optional(set(string), ["*"])

    source_prefixes      = optional(set(string), ["*"])
    destination_prefixes = optional(set(string), ["VirtualNetwork"])

    source_application_security_group_ids      = optional(set(string), null)
    destination_application_security_group_ids = optional(set(string), null)
  }))
  default = []
}

variable "nsg_rules_outbound" {
  description = "A list of objects describing a rule outbound."
  type = list(object({
    rule        = optional(string)
    name        = string
    description = optional(string, "Created by Terraform.")

    access   = optional(string, "Allow")
    priority = optional(number)

    protocol = optional(string, "*")
    ports    = optional(set(string), ["*"])

    source_prefixes      = optional(set(string), ["*"])
    destination_prefixes = optional(set(string), ["VirtualNetwork"])

    source_application_security_group_ids      = optional(set(string), null)
    destination_application_security_group_ids = optional(set(string), null)
  }))
  default = []
}

############
# Flow Logs
############

variable "flow_log_config" {
  description = "Configuration for flow logs."
  type = object({
    name                 = string
    storage_account_name = optional(string)
    storage_account_id   = optional(string)
    retention_days       = optional(number)

    enable_analytics             = optional(bool)
    log_analytics_workspace_name = optional(string)
    analytics_interval_minutes   = optional(number)
    workspace_resource_id        = optional(string)
    workspace_id                 = optional(string)
  })
  default = null

  validation {
    condition     = var.flow_log_config != null ? (var.flow_log_config.storage_account_name != null) != (var.flow_log_config.storage_account_id != null) : true
    error_message = "Either storage_account_name or storage_account_id must be set but not both"
  }

  validation {
    condition = var.flow_log_config != null ? (
      var.flow_log_config.enable_analytics ? (
        var.flow_log_config.log_analytics_workspace_name != null) != ((var.flow_log_config.workspace_resource_id != null) && (var.flow_log_config.workspace_id != null)
      ) : true
    ) : true
    error_message = "Either log_analytics_workspace_name is supplied to create a new Log Analytics Workspace or workspace_resource_id AND workspace_id from an existing Log Analytics Workspace must be specificed."
  }
}

##############
# Route Table
##############

variable "create_default_route_table" {
  description = "Create a route table to associate with all subnets."
  type        = bool
  default     = true
}

variable "route_table_name" {
  description = "Name of the default Route Table"
  type        = string
  default     = "default-rt"
}

variable "default_route" {
  description = "Configuration for the default route."
  type = object({
    name = optional(string, "default-route")
    ip   = string
  })
  default = null

  validation {
    error_message = "Must be a valid IPv4 address."
    condition     = var.default_route != null ? can(cidrhost("${var.default_route.ip}/32", 0)) : true
  }
}

variable "extra_routes" {
  description = "Routes to add to a custom route table."
  type = map(object({
    address_prefix         = string
    next_hop_type          = optional(string, "VirtualAppliance")
    next_hop_in_ip_address = optional(string)
  }))
  default = {}

  validation {
    error_message = "Value for next_hop_in_ip_address be valid IPv4 CIDR."
    condition     = alltrue([for v in var.extra_routes : can(cidrhost(v.address_prefix, 0))])
  }

  validation {
    error_message = "Value for next_hop_in_ip_address must be a valid IPv4 address."
    condition     = alltrue([for v in var.extra_routes : can(cidrhost("${v.next_hop_in_ip_address}/32", 0))])
  }
}

##################
# Network Watcher
##################

variable "enable_network_watcher" {
  description = "Enables Network Watcher for the region & subscription."
  type        = bool
  default     = true
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher"
  type        = string
  default     = null
}

variable "network_watcher_resource_group_name" {
  description = "Name of the Network Watcher Resourece Group"
  type        = string
  default     = null
}

###########
# Features
###########

variable "create_network_watcher" {
  description = "Enables Network Watcher for the region & subscription."
  type        = bool
  default     = true
}

variable "private_dns_zones" {
  description = "A set of private domains to configure."
  type = map(object({
    name                 = string
    resource_group_name  = optional(string)
    registration_enabled = optional(string)
    soa_record = optional(object({
      email        = string
      expire_time  = optional(number, 2419200)
      minimum_ttl  = optional(number, 10)
      refresh_time = optional(number, 3600)
      retry_time   = optional(number, 300)
      ttl          = optional(number, 3600)
      tags         = optional(map(string))
    }), null)
  }))
  default = {}
}

##########################
# Log Analytics Workspace
##########################

variable "log_analytics_workspace_id" {
  description = "Log analytics workspace ID to forward diagnostics to."
  type        = string
  default     = null
}
