variable "name" {
  description = "Specifies the name of the Virtual Network"
  type        = string
}

variable "virtual_network_address_space" {
  type        = list(string)
  description = "The address space that is used the virtual network. You can supply more than one address space"
  nullable    = false
  validation {
    condition     = length(var.virtual_network_address_space) > 0
    error_message = "Please provide at least one cidr as address space."
  }
}

variable "virtual_network_bgp_community" {
  type        = string
  description = "The BGP community attribute in format `<as-number>:<community-value>`. The as-number segment is the Microsoft ASN, which is always 12076 for now."
  default     = null
}

variable "virtual_network_edge_zone" {
  type        = string
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. Changing this forces a new Virtual Network to be created."
  default     = null
}

variable "virtual_network_flow_timeout_in_minutes" {
  type        = number
  description = "The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between `4` and `30`minutes."
  default     = null
  validation {
    condition     = var.virtual_network_flow_timeout_in_minutes == null ? true : (var.virtual_network_flow_timeout_in_minutes >= 4 && var.virtual_network_flow_timeout_in_minutes <= 30)
    error_message = "Possible values for `virtual_network_flow_timeout_in_minutes` are between `4` and `30`minutes."
  }
  nullable = true
}

variable "virtual_network_ddos_protection_plan" {
  type = object({
    enable = optional(bool, true)
    id     = optional(string)
  })
  description = <<EOT
  "AzureNetwork DDoS Protection Plan. This is optional, but when specified, the below attributes are required"
  "id - The ID of DDoS Protection Plan."
  "enable - Enable/disable DDoS Protection Plan on Virtual Network."
  EOT
  default     = null
}

variable "virtual_network_dns_servers" {
  type        = list(string)
  description = "List of IP addresses of DNS servers"
  default     = []
}

variable "location" {
  description = "Azure region to use."
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  nullable    = false
}