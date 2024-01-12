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
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

#########################
# Network Security Group
#########################

variable "name" {
  description = "Name of the created network security group."
  type        = string
}

#########################
# Subnet NSG Association 
#########################

variable "subnet_ids" {
  description = "A list of subnet ids to associate with this NSG."
  type        = list(string)
  default     = []
}

############
# NSG Rules
############

variable "start_priority" {
  description = "The priority number to start from when creating rules."
  type        = number
  default     = 1000
}

variable "priority_interval" {
  description = "The interval to use when moving onto the next rules' priority."
  type        = number
  default     = 5
}

variable "rules_inbound" {
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

variable "rules_outbound" {
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

variable "enable_flow_log" {
  description = "Enable flog log for this network security group."
  type        = bool
  default     = false
}

variable "flow_log_config" {
  description = "Configuration for flow logs."
  type = object({
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
  })
  default = null
}
