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
  value       = module.network_security_group[0].rules_inbound
}

output "nsg_rules_outbound" {
  description = "The output of the Outbound NSG rules."
  value       = module.network_security_group[0].rules_outbound
}

output "route_table" {
  description = "The output of the route table rsource."
  value       = one(module.route-table)
}

output "routes" {
  description = "The output of all routes, default and custom."
  value       = module.route-table[0].routes
}

output "network_watcher" {
  description = "The output of the Network Watcher."
  value       = azurerm_network_watcher.main
}

output "snet" {
  value = [for v in var.subnets : can(cidrhost("${v.address_prefixes}", 0))]
}

output "subnet_config" {
  value = var.subnets
}