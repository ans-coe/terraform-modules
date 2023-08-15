output "resource_group" {
  description = "The output of the resource group."
  value       = azurerm_resource_group.main
}

output "network_security_group" {
  description = "The output of the network security group resource."
  value       = one(module.network_security_group)
}

output "route_table" {
  description = "The output of the route table rsource."
  value       = one(azurerm_route_table.main)
}

output "network" {
  description = "The output of the network module."
  value       = module.network
}

output "network_watcher" {
  description = "Output of the network watcher."
  value       = one(azurerm_network_watcher.main)
}
