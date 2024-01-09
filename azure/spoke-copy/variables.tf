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

variable "name" {
  description = "The name of the spoke virtual network."
  type        = string
}

variable "address_space" {
  description = "The address spaces of the virtual network."
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

variable "create_global_route_table" {
  description = "Create a route table to associate with all subnets."
  type        = bool
  default     = true
}

variable "route_table_name" {
  description = "Name of the global route table to be created."
  type        = string
  default     = "default-rt"
}

variable "default_route_name" {
  description = "Name of the default route."
  type        = string
  default     = "default-route"
}

variable "default_route_ip" {
  description = "Default route IP Address."
  type        = string

  default = null

  # validation {
  #   condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.default_route_ip))
  #   error_message = "Invalid IP address provided."
  # }
}

variable "disable_bgp_route_propagation" {
  description = "Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable."
  type        = bool
  default     = true
}

variable "create_global_nsg" {
  description = "Create a Network Security Group to associate with all subnets."
  type        = bool
  default     = true
}

variable "nsg_name" {
  description = "Name of the global Network Security Group to be created."
  type        = string
  default     = "default-nsg"
}

variable "create_global_nat_gateway" {
  description = "Create a NAT Gateway to associate with all subnets."
  type = bool
  default = false
}

variable "nat_gateway_name" {
  description = "Name of the global NAT Gateway to be created."
  type        = string
  default     = "default-ngw"
}

variable "subnets" {
  description = "Subnets to create in this virtual network with the map name indicating the subnet name."
  type = map(object({
    prefixes                                      = list(string)
    resource_group_name                           = optional(string)
    service_endpoints                             = optional(list(string))
    private_endpoint_network_policies_enabled     = optional(bool)
    private_link_service_network_policies_enabled = optional(bool)
    delegations = optional(map(
      object({
        service = string
        actions = list(string)
      })
    ), {})
    associate_global_route_table = optional(bool, true)
    associate_global_nsg         = optional(bool, true)
    associate_global_nat_gateway = optional(bool, true)
  }))
  default = {}

  # validation {
  #   error_message = "Must be valid IPv4 CIDR."
  #   condition     = alltrue([for k, v in var.subnets : can(cidrhost(v.prefixes, 0))])
  # }
  # validation {
  #   error_message = "Invalid IP address provided."
  #   condition     = alltrue([for k, v in var.subnets : can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", v.default_route_ip))])
  # }
}

############
# NSG Rules
############

variable "nsg_rules_inbound" {
  description = "A list of objects describing a rule inbound for the global Network Security Group."
  type = list(object({
    rule        = optional(string)
    name        = string
    description = optional(string, "Created by Terraform.")
    nsg_name    = optional(string, "default-nsg")

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
  description = "A list of objects describing a rule outbound for the global Network Security Group."
  type = list(object({
    rule        = optional(string)
    name        = string
    description = optional(string, "Created by Terraform.")
    nsg_name    = optional(string, "default-nsg")

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

###############
# Route Tables
###############

variable "route_tables" {
  description = "A map of objects describing custom route tables with associated subnets."
  type = map(object({
    resource_group_name           = string
    disable_bgp_route_propagation = optional(bool, true)
    subnets                       = optional(list(string), null)
    routes = optional(map(object({
      address_prefix         = string
      next_hop_type          = optional(string, "VirtualAppliance")
      next_hop_in_ip_address = optional(string)
    })), {})
  }))
  default = {}
}

variable "network_security_groups" {
  description = "A map of objects describing custom Network Security Groups with associated subnets."
  type = map(object({
    location            = string
    resource_group_name = optional(string)
    subnets             = optional(list(string), null)

    enable_flow_log = optional(bool, false)
    flow_log_config = optional(object({
      version                             = optional(number, 2)
      network_watcher_name                = string
      network_watcher_resource_group_name = string
      storage_account_id                  = string
      retention_days                      = optional(number, 7)

      enable_analytics           = optional(bool, false)
      analytics_interval_minutes = optional(number, 10)
      workspace_resource_id      = optional(string)
      workspace_region           = optional(string)
      workspace_id               = optional(string)
    }), null)

    nsg_rules_inbound = optional(list(object({
      rule                                       = optional(string)
      name                                       = string
      description                                = optional(string, "Created by Terraform.")
      nsg_name                                   = optional(string, "default_nsg")
      access                                     = optional(string, "Allow")
      priority                                   = optional(number)
      protocol                                   = optional(string, "*")
      ports                                      = optional(set(string), ["*"])
      source_prefixes                            = optional(set(string), ["*"])
      destination_prefixes                       = optional(set(string), ["VirtualNetwork"])
      source_application_security_group_ids      = optional(set(string), null)
      destination_application_security_group_ids = optional(set(string), null)
    })), [])

    nsg_rules_outbound = optional(list(object({
      rule                                       = optional(string)
      name                                       = string
      description                                = optional(string, "Created by Terraform.")
      access                                     = optional(string, "Allow")
      priority                                   = optional(number)
      protocol                                   = optional(string, "*")
      ports                                      = optional(set(string), ["*"])
      source_prefixes                            = optional(set(string), ["*"])
      destination_prefixes                       = optional(set(string), ["VirtualNetwork"])
      source_application_security_group_ids      = optional(set(string), null)
      destination_application_security_group_ids = optional(set(string), null)
    })), [])
  }))
  default = {}
}

###############
# NAT Gateways
###############

variable "nat_gateways" {
  description = "A map of objects describing custom NAT Gateways with associated subnets."
  type = map(object({
    location            = string
    resource_group_name = string
    subnets             = optional(list(string), null)
  }))
  default = {}
}

##########
# Peering
##########

variable "hub_peering" {
  description = "Config for peering to the hub network."
  type = map(object({
    id                           = string
    create_reverse_peering       = optional(bool, true)
    hub_resource_group_name      = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, true)
  }))
  default = {}
}