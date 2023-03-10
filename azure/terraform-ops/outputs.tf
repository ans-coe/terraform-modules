output "service_principal" {
  description = "Service principal details."
  value = {
    display_name   = azuread_service_principal.main.display_name
    tenant_id      = azuread_service_principal.main.application_tenant_id
    object_id      = azuread_service_principal.main.object_id
    application_id = azuread_service_principal.main.application_id
  }
}

output "group" {
  description = "Group details."
  value       = { object_id = azuread_group.main.object_id }
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "storage_account" {
  description = "Storage account details."
  value = {
    id   = azurerm_storage_account.main.id
    name = azurerm_storage_account.main.name
  }
}

output "key_vault" {
  description = "Key vault details."
  value = {
    id   = azurerm_key_vault.main.id
    name = azurerm_key_vault.main.name
  }
}
