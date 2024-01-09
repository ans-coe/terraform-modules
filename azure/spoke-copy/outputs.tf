output "network_security_group" {
  description = "The output of the network security group resource."
  value       = module.global_network_security_group
}

output "route_tables" {
  description = "The output of the route table rsource."
  value       = local.route_tables
}

output "network" {
  description = "The output of the network module."
  value       = module.network
}

output "id" {
  description = "The output of the network module."
  value       = module.network.id
}

output "network_security_group_config" {
  value = local.network_security_group_config
}

output "subnets" {
  value = local.subnets
}