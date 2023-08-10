###################
# Global Variables
###################

variable "location" {
  description = "The location of the firewall."
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
}

#############
# Network
#############

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

#############
# Firewall Policy
#############

# variable "firewall_policy_name" {
#   description = "Name of the Firewall Policy"
#   default     = null
# }

# variable "firewall_policy_sku" {
#   description = "SKU of the Firewall Policy"
#   type        = string
#   default     = "Standard"

#   validation {
#     condition     = contains(["Basic", "Standard", "Premium"], var.firewall_policy_sku)
#     error_message = "Value must be Basic, Standard or Premium."
#   }
# }

# variable "firewall_policy_base_policy_id" {
#   description = "The ID of the base Firewall Policy"
#   type        = string
#   default     = null
# }

# variable "firewall_policy_threat_intelligence_mode" {
#   description = "The operation mode for Threat Intelligence"
#   type        = string
#   default     = "Alert"

#   validation {
#     condition     = contains(["Alert", "Deny", "Off"], var.firewall_policy_threat_intelligence_mode)
#     error_message = "Value must be Alert, Deny or Off."
#   }
# }

# variable "firewall_policy_dns" {
#   description = "Proxy enabled (true/false) and list of DNS Servers"
#   type = object({
#     servers       = optional(list(string))
#     proxy_enabled = optional(bool)
#   })
# }

# variable "firewall_policy_threat_intelligence_allow_list" {
#   description = "A list of FQDNs, IPs or CIDR ranges that will be skipped for threat detection"
#   type = object({
#     ip_addresses = list(string)
#     fqdns        = list(string)
#   })
#   default = null
# }

# #############
# # Firewall Rules (Network, Application, NAT)
# #############

# variable "firewall_application_rules" {
#   description = "List of application rules to apply to firewall."
#   type = list(object({
#     name             = string
#     description      = optional(string)
#     action           = string
#     source_addresses = optional(list(string))
#     source_ip_groups = optional(list(string))
#     fqdn_tags        = optional(list(string))
#     target_fqdns     = optional(list(string))
#     protocol = optional(object({
#       type = string
#       port = string
#     }))
#   }))
#   default = []
# }

# variable "firewall_network_rules" {
#   description = "List of network rules to apply to firewall."
#   type = list(object({
#     name                  = string
#     description           = optional(string)
#     action                = string
#     source_addresses      = optional(list(string))
#     destination_ports     = list(string)
#     destination_addresses = optional(list(string))
#     destination_fqdns     = optional(list(string))
#     protocols             = list(string)
#   }))
#   default = []
# }

# variable "firewall_nat_rules" {
#   description = "List of nat rules to apply to firewall."
#   type = list(object({
#     name                  = string
#     description           = optional(string)
#     action                = string
#     source_addresses      = optional(list(string))
#     destination_ports     = list(string)
#     destination_addresses = list(string)
#     protocols             = list(string)
#     translated_address    = string
#     translated_port       = string
#   }))
#   default = []
# }

#############
# Monitoring
#############

# variable "firewall_pip_diag_logs" {
#   description = "Firewall Public IP Monitoring Category details for Azure Diagnostic setting"
#   default     = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
# }

# variable "firewall_diag_logs" {
#   description = "Firewall Monitoring Category details for Azure Diagnostic setting"
#   default     = ["AzureFirewallApplicationRule", "AzureFirewallNetworkRule", "AzureFirewallDnsProxy"]
# }

# variable "log_analytics_workspace_id" {
#   description = "The resource id of log analytics workspace"
#   default     = null
# }

# variable "log_storage_account_name" {
#   description = "The name of the hub storage account to store logs"
#   default     = null
# }