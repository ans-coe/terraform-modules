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

##########
# Network
##########

variable "subnet_ids" {
  description = "A list of Subnet IDs to associate with this Route Table."
  type = map(string)
  default = null
}


##############
# Route Table
##############

variable "route_table_name" {
  description = "Name of the Route Table"
  type        = string
  default     = ""
}

variable "disable_bgp_route_propagation" {
  description = "Disable Route Propagation for the Route Table. True = Disabled"
  type        = bool
  default     = true
}

variable "route" {
  description = "Details of a route to be added to the Route Table with the name of the route as the key."
  type        = map(object({
    address_prefix = string
    next_hop_type = optional(string, "VirtualAppliance")
    next_hop_in_ip_address = optional(string)
  }))
  default     = {}
}