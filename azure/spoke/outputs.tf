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

output "nsg_rules_inbound" {
  description = "The output of the Inbound NSG rules."
  value       = one(module.network_security_group.rules_inbound)
}

output "nsg_rules_outbound" {
  description = "The output of the Outbound NSG rules."
  value       = one(module.network_security_group.rules_outbound)
}

output "route_table" {
  description = "The output of the route table rsource."
  value       = one(module.route-table)
}

output "routes" {
  description = "The output of all routes, default and custom."
  value       = one(module.route-table).routes
}

output "network_watcher" {
  description = "The output of the Network Watcher."
  value       = one(azurerm_network_watcher.main)
}

output "flow_log" {
  value = one(module.network_security_group.flow_log)
}

output "flow_log_sa" {
  description = "The output of the flow log storage account."
  value       = azurerm_storage_account.flow_log_sa
}

output "flow_log_law" {
  description = "The output of the flow log log analytics workspace."
  value       = azurerm_log_analytics_workspace.flow_log_law
}