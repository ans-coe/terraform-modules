output "id" {
  description = "Resource ID of the application gateway."
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

output "ip" {
  description = "IP address of the application gateway."
  value       = one(azurerm_public_ip.main_agw[*].ip_address)
}

output "private_ip" {
  description = "Private IP address of the application gateway."
  value = one([
    for ipconfig in azurerm_application_gateway.main.frontend_ip_configuration[*]
    : ipconfig.private_ip_address
    if ipconfig.private_ip_address != ""
  ])
}

output "backend_address_pools" {
  description = "Backend address pools on the application gateway."
  value = {
    for pool in azurerm_application_gateway.main.backend_address_pool[*]
    : pool.name => pool.id
  }
}
