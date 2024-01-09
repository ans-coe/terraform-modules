output "id" {
  description = "ID of the Route Table."
  value       = azurerm_route_table.main.id
}

output "location" {
  description = "Location of the Route Table."
  value       = azurerm_route_table.main.location
}

output "name" {
  description = "Name of the Route Table."
  value       = azurerm_route_table.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_route_table.main.resource_group_name
}

output "route_table_association" {
  description = "A map of objects containing the Route Table association details per associated subnet."
  value       = azurerm_subnet_route_table_association.main
}