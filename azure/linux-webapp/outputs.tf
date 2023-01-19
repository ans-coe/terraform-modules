output "id" {
  description = "ID of the app service."
  value       = azurerm_linux_web_app.main.id
}

output "name" {
  description = "Name  of the app service."
  value       = azurerm_linux_web_app.main.name
}

output "identity" {
  description = "Identity of the app service."
  value       = one(azurerm_linux_web_app.main.identity[*])
}

output "app_service_plan_id" {
  description = "ID of the service plan."
  value       = one(azurerm_service_plan.main[*].id)
}

output "fqdn" {
  description = "Default FQDN of the app service."
  value       = azurerm_linux_web_app.main.default_hostname
}
