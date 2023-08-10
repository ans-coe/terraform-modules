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

variable "test" {
  description = "test"
  type        = string
  default     = null
}

variable "firewall_policies" {
  description = "List of Firewall Policies"
  type = map(object({

    location                 = string
    resource_group_name      = string
    sku                      = string
    base_policy_id           = optional(string)
    threat_intelligence_mode = string

    dns = optional(object({
      servers       = optional(list(string))
      proxy_enabled = optional(bool)
    }))

    threat_intelligence_allow_list = optional(map(object({
      ip_addresses = list(string)
      fqdns        = list(string)
    })))

    #############
    # Firewall Policy Rule Collection Group
    #############

    rule_collection_groups = map(object({
      priority = string

      application_rule_collection = optional(map(object({
        description = optional(string)
        action      = string
        priority    = string
        rule = map(object({
          protocols             = optional(map(string))
          source_addresses      = optional(list(string))
          source_ip_groups      = optional(list(string))
          destination_addresses = optional(list(string))
          destination_urls      = optional(list(string))
          destination_fqdns     = optional(list(string))
          destination_fqdn_tags = optional(list(string))
        }))
      })))

      network_rule_collection = optional(map(object({
        description = optional(string)
        action      = string
        priority    = string
        rule = map(object({
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
        description = optional(string)
        priority    = string
        action      = string
        rule = map(object({
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
  }))
}