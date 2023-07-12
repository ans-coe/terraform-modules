###################
# Global Variables
###################

variable "location" {
  description = "The location of created resources."
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

#############
# Firewall Policy
#############

variable "firewall_policies" {
  description = "List of Firewall Policies"
  type = map(object({
    name                     = string
    sku                      = string
    base_policy_id           = optional(string)
    threat_intelligence_mode = string
    dns = optional(object({
      servers       = optional(list(string))
      proxy_enabled = optional(bool)
    }))
    threat_intelligence_allow_list = optional(object({
      ip_addresses = list(string)
      fqdns        = list(string)
    }))
  }))
}

#############
# Firewall Policy Rule Collection Group
#############

variable "firewall_policy_rule_collection_groups" {
  description = "Firewall Rule Collection Groups, Collections and Rules"
  type = map(object({
    name               = string
    firewall_policy_id = optional(string)
    firewall_policy_name = string
    priority           = string

    application_rule_collection = optional(map(object({
      name        = string
      description = optional(string)
      action      = string
      priority    = string
      rule = map(object({
        name = string
        protocols = optional(map(object({
          type = string
          port = string
        })))
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_urls      = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
      }))
    })))

    network_rule_collection = optional(map(object({
      name        = string
      description = optional(string)
      action      = string
      priority    = string
      rule = map(object({
        name                  = string
        protocols             = list(string) #Any, TCP, UDP, ICMP
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_ip_groups = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_ports     = list(string)
      }))
    })))

    nat_rule_collection = optional(map(object({
      name        = string
      description = optional(string)
      priority    = string
      action      = string
      rule = map(object({
        name                = string
        protocols           = list(string) #TCP or UDP
        source_addresses    = optional(list(string))
        source_ip_groups    = optional(list(string))
        destination_address = optional(string)
        destination_ports   = optional(list(string))
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = string
      }))
    })))
  }))
}