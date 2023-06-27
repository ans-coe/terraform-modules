output "id" {
  description = "ID of the application gateway."
  value       = azurerm_application_gateway.main.id
}

output "location" {
  description = "Location of the application gateway."
  value       = azurerm_application_gateway.main.location
}

output "name" {
  description = "Name of the application gateway."
  value       = azurerm_application_gateway.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = var.resource_group_name
}

output "backend_address_pool" {
  description = "List of objects of Backend Address Pools"
  value       = azurerm_application_gateway.main.backend_address_pool[*]
}

output "frontend_ip_configuration" {
  description = "List of objects of Frontend IP Configurations"
  value       = azurerm_application_gateway.main.frontend_ip_configuration[*]
}

output "identity_id" {
  description = "Identity of the AppGW if KV is used."
  value = azurerm_user_assigned_identity.main_gateway[0].id  
}