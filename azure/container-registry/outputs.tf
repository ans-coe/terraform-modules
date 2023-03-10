output "id" {
  description = "Resource ID of the container registry."
  value       = azurerm_container_registry.main.id
}

output "location" {
  description = "Location of the container registry."
  value       = azurerm_container_registry.main.location
}

output "name" {
  description = "Name of the container registry."
  value       = azurerm_container_registry.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = local.resource_group_name
}

output "login_server" {
  description = "Login server of the container registry."
  value       = azurerm_container_registry.main.login_server
}

output "admin_user" {
  description = "Admin user for the container registry."
  value       = azurerm_container_registry.main.admin_username
}

output "admin_password" {
  description = "Admin password for the container registry."
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "scope_maps" {
  description = "Scope maps created with this module."
  value       = azurerm_container_registry_scope_map.main
}
