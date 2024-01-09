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

variable "address_space" {
  description = "The address spaces of the virtual network."
  type        = list(string)

  validation {
    error_message = "Must be valid IPv4 CIDR."
    condition     = can(cidrhost(one(var.address_space[*]), 0))
  }
}

variable "subnets" {
  description = "Subnets to create in this virtual network with the map name indicating the subnet name."
  type = map(object({
    prefix                                        = string
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
    create_default_route_table    = optional(bool, true)
    default_route_table_name      = optional(string, "default_rt")
    default_route_name            = optional(string, "default_route")
    default_route_ip              = optional(string)
    disable_bgp_route_propagation = optional(bool, true)

    create_custom_route_table = optional(bool, false)
    custom_route_table_name   = optional(string)

    associate_existing_route_table = optional(bool, false)
    existing_route_table_id        = optional(string)

    create_subnet_nsg = optional(bool, true)
    subnet_nsg_name   = optional(string, "default_nsg")

    # associate_existing_nsg = optional(bool, false)
    # existing_nsg_id        = optional(string)
  }))
  default = {}

  validation {
    error_message = "Must be valid IPv4 CIDR."
    condition     = alltrue([for k, v in var.subnets : can(cidrhost(v.prefix, 0))])
  }
  validation {
    error_message = "Invalid IP address provided."
    condition     = alltrue([for k, v in var.subnets : can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", v.default_route_ip))])
  }
  # validation {
  #   error_message = "Can only have one of the following enabled: 'create_default_route_table', 'create_custom_route_table', 'associate_existing_route_table'."
  #   condition     = alltrue([for k, v in var.subnets : try((v.subnets.create_default_route_table ? 1 : 0) + (v.subnets.create_custom_route_table ? 1 : 0) + (v.subnets.associate_existing_route_table ? 1 : 0) <= 1)])
  # }
}

############
# NSG Rules
############

variable "nsg_rules_inbound" {
  description = "A list of objects describing a rule inbound."
  type = list(object({
    rule        = optional(string)
    name        = string
    nsg_name    = string
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
    nsg_name    = string
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

#########
# Routes
#########

variable "custom_routes" {
  description = "Routes to add to a custom route table."
  type = map(object({
    route_table_name       = string
    address_prefix         = string
    next_hop_type          = optional(string, "VirtualAppliance")
    next_hop_in_ip_address = optional(string)
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