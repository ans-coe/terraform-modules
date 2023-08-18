output "id" {
  description = "ID of the bastion."
  value       = azurerm_bastion_host.main.id
}

output "location" {
  description = "Location of the bastion."
  value       = azurerm_bastion_host.main.location
}

output "name" {
  description = "Name of the bastion."
  value       = azurerm_bastion_host.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = var.resource_group_name
}