output "firewall_name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.main.name
}

output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.main.id
}

output "firewall_public_ip" {
  description = "The public ip of firewall."
  value       = azurerm_public_ip.main.ip_address
}