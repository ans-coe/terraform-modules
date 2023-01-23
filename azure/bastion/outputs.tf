output "id" {
  description = "ID of the bastion."
  value       = azurerm_bastion_host.main.id
}

output "name" {
  description = "Name of the bastion."
  value       = azurerm_bastion_host.main.name
}

output "resource_group_name" {
  description = "Resource group name of the bastion."
  value       = azurerm_bastion_host.main.resource_group_name
}
