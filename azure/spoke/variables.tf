###################
# Global Variables
###################

variable "location" {
  description = "The location of created resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
}

##########
# Network
##########

variable "virtual_network_name" {
  description = "The name of the spoke virtual network."
  type        = string
}

variable "address_space" {
  description = "The address spaces of the virtual network."
  type        = list(string)

  validation {
    error_message = "Values for address_space must be valid IPv4 CIDR."
    condition     = alltrue([for v in var.address_space : can(cidrhost(v, 0))])
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

variable "private_dns_zones" {
  description = "Private DNS Zones to link to this virtual network with the map name indicating the private dns zone name."
  type = map(object({
    resource_group_name  = string
    registration_enabled = optional(bool)
  }))
  default = {}
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
    prefixs                                       = string
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

##########
# Peering
##########

variable "vnet_peering" {
  description = "Configuration for peering spoke Virtual Network to another hub/spoke Virtual Network with the remote Virtual Network name as the key."
  type = map(object({
    remote_vnet_id               = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, true)
  }))
  default = {}
}
