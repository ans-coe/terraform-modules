output "network" {
  description = "The output of the network module."
  value       = module.network
}

output "id" {
  description = "The output of the network module."
  value       = module.network.id
}

output "subnets" {
  description = "The output of the subnets."
  value       = azurerm_subnet.main
}

output "network_security_group" {
  description = "The output of the network security group resource."
  value       = module.network_security_group
}

output "route_table" {
  description = "The output of the route table rsource."
  value       = azurerm_route_table.main
}

output "routes" {
  description = "The output of all routes, default and custom."
  value       = local.routes
}

output "network_watcher" {
  description = "The output of the Network Watcher."
  value       = azurerm_network_watcher.main
}