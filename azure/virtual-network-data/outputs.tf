output "id" {
  description = "ID of the virtual network."
  value       = data.azurerm_virtual_network.main.id
}

output "location" {
  description = "Location of the virtual network."
  value       = data.azurerm_virtual_network.main.location
}

output "name" {
  description = "Name of the virtual network."
  value       = data.azurerm_virtual_network.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = data.azurerm_virtual_network.main.resource_group_name
}

output "dns_servers" {
  description = "The list of DNS servers used by the virtual network."
  value       = data.azurerm_virtual_network.main.dns_servers
}

output "guid" {
  description = "The GUID of the virtual network."
  value       = data.azurerm_virtual_network.main.guid
}

output "address_space" {
  description = "Address space of the virtual network."
  value       = data.azurerm_virtual_network.main.address_space
}

output "vnet_peerings" {
  description = "A mapping of name - virtual network id of the virtual network peerings."
  value       = data.azurerm_virtual_network.main.vnet_peerings

}

output "vnet_peerings_addresses" {
  description = "A list of virtual network peerings IP addresses."
  value       = data.azurerm_virtual_network.main.vnet_peerings_addresses
}

output "subnets" {
  description = "The list of name of the subnets that are attached to this virtual network."
  value = {
    for s in data.azurerm_subnet.main
    : s.name => {
      name             = s.name
      address_prefixes = s.address_prefixes
      id               = s.id
      network_security_groups = {
        for n in s.network_security_group_id
        : data.azurerm_network_security_group.main[n].name => {
          id            = n
          security_rule = data.azurerm_network_security_group.main[n].security_rule
          security_rule = data.azurerm_network_security_group.main[n].tags
        }
      }
      route_tables = {
        for r in s.route_table_id
        : data.azurerm_route_table.main[r].name => {
          id      = r
          route   = data.azurerm_route_table.main[r].route
          subnets = data.azurerm_route_table.main[r].subnets
          tags    = data.azurerm_route_table.main[r].tags
        }
      }
    }
  }
}