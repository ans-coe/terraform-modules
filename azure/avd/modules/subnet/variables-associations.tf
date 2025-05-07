variable "nat_gateway_enabled" {
  type        = bool
  description = "Should 'NAT Gateway association' be enabled for the subnet."
  default     = false
}

variable "nat_gateway_id" {
  type        = string
  description = "The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created."
  default     = null
}

variable "route_table_enabled" {
  type        = bool
  description = "Should 'Route Table association' be enabled for the subnet."
  default     = false
}

variable "route_table_id" {
  type        = string
  description = "The ID of the Route Table which should be associated with the Subnet. Changing this forces a new resource to be created."
  default     = null
}

variable "network_security_group_enabled" {
  type        = bool
  description = "Should 'Network Security Group association' be enabled for the subnet."
  default     = false
}

variable "network_security_group_id" {
  type        = string
  description = "The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new resource to be created."
  default     = null
}
