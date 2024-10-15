output "virtual_network_id" {
  description = "Virtual Network Identity"
  value       = azurerm_virtual_network.vnet.id
}

output "location" {
  description = "Virtual Network location"
  value       = azurerm_virtual_network.vnet.location
}

output "virtual_network_guid" {
  description = "Virtual Network GUID"
  value       = azurerm_virtual_network.vnet.guid
}

output "virtual_network_name" {
  description = "Virtual Network Name"
  value       = azurerm_virtual_network.vnet.name
}
