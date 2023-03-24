output "id" {
  description = "ID of the function app."
  value       = azurerm_linux_function_app.main.id
}

output "location" {
  description = "Location of the function app."
  value       = azurerm_linux_function_app.main.location
}

output "name" {
  description = "Name  of the function app."
  value       = azurerm_linux_function_app.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = local.resource_group_name
}

output "identity" {
  description = "Identity of the function app."
  value       = one(azurerm_linux_function_app.main.identity)
}

output "app_service_plan_id" {
  description = "ID of the service plan."
  value       = one(azurerm_service_plan.main[*].id)
}

output "fqdn" {
  description = "Default FQDN of the function app."
  value       = azurerm_linux_function_app.main.default_hostname
}

output "slots" {
  description = "Object containing details for the created slots."
  value       = azurerm_linux_function_app_slot.main
}
