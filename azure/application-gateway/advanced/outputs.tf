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
  value       = try(azurerm_user_assigned_identity.main_gateway[0].id, null)
}

output "identity_principal_id" {
  description = "principal_id of the AppGW if KV is used."
  value       = try(azurerm_user_assigned_identity.main_gateway[0].principal_id, null)
}

output "private_ip" {
  description = "Private IP Address"
  value = one([
    for ipconfig in azurerm_application_gateway.main.frontend_ip_configuration[*]
    : ipconfig.private_ip_address
    if ipconfig.name == "private_frontend"
  ])
}

output "key_vault_id" {
  description = "The id of the keyvault if one is set"
  value = try(coalesce(
    try(azurerm_key_vault.main[0].id, null), // try use the created keyvault ID first
    var.key_vault_id,                        // next, try to use the variable inputted
    ),
    null // if use_key_vault is false, no keyvault will be set so this should be null
  )
}

output "public_ip" {
  description = "Public IP Address"
  value       = one(azurerm_public_ip.main[*].ip_address)
}