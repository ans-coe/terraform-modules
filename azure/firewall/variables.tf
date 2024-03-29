###################
# Global Variables
###################

variable "location" {
  description = "The location of the firewall."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
}

##########
# Network
##########

variable "virtual_network_name" {
  description = "Name of your Azure Virtual Network"
  type        = string
}

variable "pip_name" {
  description = "Name of the firewall's public IP"
  type        = string
  default     = null
}

variable "subnet_address_prefixes" {
  description = "The subnet used for the firewall must have the name `AzureFirewallSubnet` and a subnet mask of at least /26"
  type        = list(string)
}

#############
# Firewall
#############

variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
}

variable "firewall_sku_name" {
  description = "Properties relating to the SKU Name of the Firewall"
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.firewall_sku_name)
    error_message = "Value must be AZFW_Hub or AZFW_VNet"
  }
}

variable "firewall_sku_tier" {
  description = "Properties relating to the SKU Tier of the Firewall"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Value must be Basic, Standard or Premium."
  }
}

variable "firewall_dns_servers" {
  description = "List of DNS Servers for Firewall config"
  type        = list(string)
  default     = null
}

variable "private_ip_ranges" {
  description = "A list of SNAT private CIDR IP ranges, or the special string IANAPrivateRanges, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918."
  type        = list(string)
  default     = null

  validation {
    error_message = "All elements must be valid IPv4 CIDR block addresses."
    condition     = (var.private_ip_ranges == null || can([for v in var.private_ip_ranges : cidrhost(v, 0)]))
  }
}

variable "firewall_policy_id" {
  description = "The ID of the Firewall Policy applied to this Firewall"
  type        = string
  default     = null
}


variable "zone_redundant" {
  description = "Specifies whether or not the Firewall is Zone Redundant."
  type = bool
  default = true
}