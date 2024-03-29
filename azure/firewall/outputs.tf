output "name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.main.name
}

output "id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.main.id
}

output "public_ip" {
  description = "The public IP Address of firewall."
  value       = azurerm_public_ip.main.ip_address
}

output "private_ip" {
  description = "The private IP Address of the firewall"
  value       = one(azurerm_firewall.main.ip_configuration[*].private_ip_address)
}
