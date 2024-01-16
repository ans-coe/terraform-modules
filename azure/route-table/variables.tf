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
  type        = list(string)
  default     = null
}

##############
# Route Table
##############

variable "name" {
  description = "Name of the Route Table"
  type        = string
}

variable "disable_bgp_route_propagation" {
  description = "Disable Route Propagation for the Route Table. True = Disabled"
  type        = bool
  default     = true
}

#########
# Routes
#########

variable "routes" {
  description = "Details of a route to be added to the Route Table with the name of the route as the key."
  type = map(object({
    address_prefix         = string
    next_hop_type          = optional(string, "VirtualAppliance")
    next_hop_in_ip_address = optional(string)
  }))
  default = {}

  validation {
    error_message = "address_prefix must be valid IPv4 CIDR."
    condition     = alltrue(flatten([for v in var.routes : can(cidrhost("${v.address_prefix}", 0))]))
  }
}

variable "default_route_ip" {
  description = "The next hop IP address for the default route (0.0.0.0/0). If none is specified, no route is created."
  type        = string
  default     = null

  validation {
    error_message = "Must be a valid IPv4 address."
    condition     = can(cidrhost("${var.default_route_ip}/32", 0))
  }
}

variable "default_route_name" {
  description = "The name of the default route."
  type        = string
  default     = "default-route"
}