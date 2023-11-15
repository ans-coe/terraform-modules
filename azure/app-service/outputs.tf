locals {
  output_map = {
    id = {
      Windows = azurerm_windows_web_app.main.id
      Linux   = azurerm_linux_web_app.main.id
    }

  }
}

output "id" {
  description = "ID of the app service."
  value       = output_map.id[var.os_type]
}

output "location" {
  description = "Location of the app service."
  value       = azurerm_windows_web_app.main.location
}

output "name" {
  description = "Name of the app service."
  value       = azurerm_windows_web_app.main.name
}

output "identity" {
  description = "Identity of the app service."
  value       = one(azurerm_windows_web_app.main.identity)
}

output "app_service_plan_id" {
  description = "ID of the service plan."
  value       = local.plan_id
}

output "fqdn" {
  description = "Default FQDN of the app service."
  value       = azurerm_windows_web_app.main.default_hostname
}

output "app_service" {
  description = "Output containing the main app service."
  value       = azurerm_windows_web_app_slot.main
}

output "slots" {
  description = "Object containing details for the created slots."
  value       = azurerm_windows_web_app_slot.main
}
