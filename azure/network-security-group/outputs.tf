output "id" {
  description = "Resource ID of the network security group."
  value       = azurerm_network_security_group.main.id
}

output "location" {
  description = "Location of the network security group."
  value       = azurerm_network_security_group.main.location
}

output "name" {
  description = "Name of the network security group."
  value       = azurerm_network_security_group.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_network_security_group.main.resource_group_name
}

output "subnet_associations" {
  description = "The output of the subnets associated with this NSG."
  value = azurerm_subnet_network_security_group_association.main
}

output "subnet_ids" {
  description = "The output of subnet IDs associated with this NSG"
  value = var.subnet_ids
}

output "rules_inbound" {
  description = "The output of the Inbound NSG rules."
  value = azurerm_network_security_rule.inbound  
}

output "rules_outbound" {
  description = "The output of the Outbound NSG rules."
  value = azurerm_network_security_rule.outbound  
}