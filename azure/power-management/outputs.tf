output "id" {
  description = "ID of the automation account."
  value       = azurerm_automation_account.main.id
}

output "location" {
  description = "Location of the automation account."
  value       = azurerm_automation_account.main.location
}

output "name" {
  description = "Name of the automation account."
  value       = azurerm_automation_account.main.name
}

output "identity" {
  description = "The automation account identity."
  value       = one(azurerm_automation_account.main.identity)
}

output "main_runbooks" {
  description = "Name of the main power management runbook."
  value = {
    for k, v in azurerm_automation_runbook.power_management
    : k => v
  }
}

output "schedules" {
  description = "Output of created weekdays schedules."
  value       = azurerm_automation_schedule.weekdays
}
