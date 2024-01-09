output "id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "location" {
  description = "Location of the virtual network."
  value       = azurerm_virtual_network.main.location
}

output "name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = var.resource_group_name
}

output "address_space" {
  description = "Address space of the virtual network."
  value       = azurerm_virtual_network.main.address_space
}