variable "name" {
  description = "The Name which should be used for this Network Security Group."
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "security_rules" {
  type        = any
  description = <<EOT
  "A list of security rules to add to the security group. Each rule should be a map of values to add. See the Readme.md file for further details."
    security_rules = {
      name : "The name of the security rule."
      priority : "Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule."
      direction : "A description for this rule. Restricted to 140 characters."
      access : "Specifies whether network traffic is allowed or denied. Possible values are 'Allow' and 'Deny'."
      protocol : "Network protocol this rule applies to. Possible values include 'Tcp', 'Udp', 'Icmp', 'Esp', 'Ah' or '*' (which matches all)."
      source_port_range : "Source Port or Range. Integer or range between '0' and '65535' or '*' to match any. This is required if 'source_port_ranges' is not specified."
      source_port_ranges : "List of source ports or port ranges. This is required if 'source_port_range' is not specified."
      destination_port_range : "Destination Port or Range. Integer or range between '0' and '65535' or '*' to match any. This is required if 'destination_port_ranges' is not specified."
      destination_port_ranges : "List of destination ports or port ranges. This is required if 'destination_port_range' is not specified."
      source_address_prefix : "'CIDR 'or 'source IP range' or '*' to match any IP. Tags such as 'VirtualNetwork', 'AzureLoadBalancer' and 'Internet' can also be used. This is required if 'source_address_prefixes' is not specified."
      source_address_prefixes : "List of source address prefixes. Tags may not be used. This is required if 'source_address_prefix' is not specified."
      destination_address_prefix : "'CIDR' or 'destination IP range' or '*' to match any IP. Tags such as 'VirtualNetwork', 'AzureLoadBalancer' and 'Internet' can also be used. This is required if 'destination_address_prefixes' is not specified."
      destination_address_prefixes : "List of destination address prefixes. Tags may not be used. This is required if 'destination_address_prefix' is not specified."
      source_application_security_group_ids : "A List of source Application Security Group IDs."
      destination_application_security_group_ids : "A List of destination Application Security Group IDs."
    }
  EOT
  nullable    = false
}
