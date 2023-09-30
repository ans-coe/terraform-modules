#########
# Locals
#########

locals {
  enable_private_endpoint_subnet = var.private_endpoint_subnet != null

  enable_firewall      = var.firewall_config != null
  firewall             = one(module.firewall)
  firewall_route_table = one(azurerm_route_table.firewall)

  enable_bastion                = var.bastion_config != null
  bastion                       = one(module.bastion)
  bastion_create_resource_group = var.bastion_config.resource_group_name != null
  bastion_resource_group_name   = var.bastion_config.resource_group_name != null ? var.bastion_config.resource_group_name : azurerm_resource_group.main.name
  bastion_subnet                = local.enable_bastion ? module.network.subnets["AzureBastionSubnet"] : null

  enable_virtual_network_gateway = var.virtual_network_gateway_config != null
  virtual_network_gateway        = one(azurerm_virtual_network_gateway.main)
  virtual_network_gateway_subnet = local.enable_virtual_network_gateway ? module.network.subnets["GatewaySubnet"] : null

  enable_private_resolver            = var.private_resolver_config != null
  private_resolver                   = one(azurerm_private_dns_resolver.main)
  private_resolver_inbound_endpoint  = one(azurerm_private_dns_resolver_inbound_endpoint.main)
  private_resolver_outbound_endpoint = one(azurerm_private_dns_resolver_outbound_endpoint.main)
  private_resolver_inbound_subnet    = local.enable_private_resolver ? module.network.subnets[var.private_resolver_config["inbound_subnet_name"]] : null
  private_resolver_outbound_subnet   = local.enable_private_resolver ? module.network.subnets[var.private_resolver_config["outbound_subnet_name"]] : null

  enable_network_watcher = var.network_watcher_config != null
}
