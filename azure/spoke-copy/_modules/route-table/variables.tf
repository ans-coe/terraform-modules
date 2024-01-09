#########
# Global
#########

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

#####################
# Route Table Config
#####################

variable "name" {
  description = "The name of the route table."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to associate the Route Table to."
  type        = list(string)
  default     = null
}

variable "disable_bgp_route_propagation" {
  description = "Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable."
  type        = bool
  default     = true
}

#########
# Routes
#########

variable "routes" {
  description = "A map of objects describing Routes assigned to this Route Table"
  type = map(object({
    address_prefix         = string
    next_hop_type          = optional(string, "VirtualAppliance")
    next_hop_in_ip_address = optional(string)
  }))
  default = null
}