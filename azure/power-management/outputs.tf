output "id" {
  description = "ID of the created automation account."
  value       = azurerm_automation_account.main.id
}

output "name" {
  description = "Name of the created automation account."
  value       = azurerm_automation_account.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = local.resource_group_name
}

output "identity" {
  description = "Automation account identity."
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
