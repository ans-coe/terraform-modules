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
  value       = azurerm_user_assigned_identity.main_gateway[0].id
}

output "private_ip" {
  description = "Private IP Address"
  value = one([
    for ipconfig in azurerm_application_gateway.main.frontend_ip_configuration[*]
    : ipconfig.private_ip_address
    if ipconfig.private_ip_address != ""
  ])
}

output "public_ip" {
  description = "Public IP Address"
  value       = one(azurerm_public_ip.main[*].ip_address)
}

// temp for testing
output "azurerm_sub_tenant" {
  value = data.azurerm_subscription.current.tenant_id
}
output "azuread_sub_tenant" {
  value = data.azuread_client_config.current.tenant_id
}
output "azurerm_cc_sub_tenant" {
  value = data.azurerm_client_config.current.tenant_id
}