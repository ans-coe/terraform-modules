output "id" {
  description = "Resource ID of the network security group."
  value       = azurerm_network_security_group.main.id
}

output "location" {
  description = "Location of the network security group."
  value       = azurerm_network_security_group.main.location
}

output "name" {
  description = "Name of the network security group."
  value       = azurerm_network_security_group.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_network_security_group.main.resource_group_name
}
