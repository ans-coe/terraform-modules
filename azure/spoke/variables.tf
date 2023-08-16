variable "location" {
  description = "The location of created resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
}

variable "network_security_group_name" {
  description = "The name of the network security group."
  type        = string
  default     = null
}

variable "route_table_name" {
  description = "The name of the route table."
  type        = string
  default     = null
}

variable "default_route_ip" {
  description = "The IP address to use for the default route if creating a route table."
  type        = string
  default     = null
}

variable "virtual_network_name" {
  description = "The name of the spoke virtual network."
  type        = string
}

variable "dns_servers" {
  description = "The DNS servers to use with this virtual network."
  type        = list(string)
  default     = []
}

variable "address_space" {
  description = "The address spaces of the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Subnets to create in this virtual network with the map name indicating the subnet name."
  type = map(object({
    prefix                                        = string
    service_endpoints                             = optional(list(string))
    private_endpoint_network_policies_enabled     = optional(bool)
    private_link_service_network_policies_enabled = optional(bool)
    delegations = optional(map(
      object({
        service = string
        actions = list(string)
      })
    ), {})
  }))
  default = {}
}

variable "hub_virtual_network_id" {
  description = "The ID of the hub virtual network."
  type        = string
  default     = null
}

variable "use_remote_gateways" {
  description = "Use remote gateways on the hub."
  type        = bool
  default     = null
}

variable "network_watcher_config" {
  description = "Configuration for the network watcher resource."
  type = object({
    name                = optional(string)
    resource_group_name = optional(string)
  })
  default = null
}
