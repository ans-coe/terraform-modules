#########
# Locals
#########

locals {
  enable_private_endpoint_subnet = var.private_endpoint_subnet != null

  ###########
  # Firewall
  ###########

  enable_firewall = var.firewall != null
  firewall        = one(module.firewall)

  ###########
  # Route Table
  ###########

  default_route = var.create_default_route ? (        // create default route is false, don't create default route 
    var.default_route != null ? var.default_route : ( // default route is set = use default route
      local.enable_firewall ? {                       // default route is empty and azure firewall = use azure firewall
        name = "default-route"
        ip   = one(module.firewall[*].private_ip)
      } : {} // default route is empty and no azure firewall = don't create default route
    )
  ) : {}

  route_table = module.route-table

  ##########
  # Bastion
  ##########

  enable_bastion = var.bastion != null
  bastion        = one(module.bastion)

  create_bastion_resource_group = local.enable_bastion ? var.bastion["create_resource_group"] : false

  bastion_resource_group_name = local.create_bastion_resource_group ? (
    one(azurerm_resource_group.bastion[*].name)
    ) : (
    try(var.bastion["resource_group_name"], null) != null ? var.bastion["resource_group_name"] : azurerm_resource_group.main.name
  )

  bastion_subnet = local.enable_bastion ? module.network.subnets["AzureBastionSubnet"] : null

  ##########################
  # Virtual Network Gateway
  ##########################

  enable_virtual_network_gateway = var.virtual_network_gateway != null
  virtual_network_gateway        = one(azurerm_virtual_network_gateway.main)

  virtual_network_gateway_subnet = local.enable_virtual_network_gateway ? module.network.subnets["GatewaySubnet"] : null

  use_virtual_network_gateway_route_table = var.virtual_network_gateway["route_table"] != null

  ###################
  # Private Resolver
  ###################

  enable_private_resolver            = var.private_resolver != null
  private_resolver                   = one(azurerm_private_dns_resolver.main)
  private_resolver_inbound_endpoint  = one(azurerm_private_dns_resolver_inbound_endpoint.main)
  private_resolver_outbound_endpoint = one(azurerm_private_dns_resolver_outbound_endpoint.main)
  private_resolver_inbound_subnet    = local.enable_private_resolver ? module.network.subnets[var.private_resolver["inbound_subnet_name"]] : null
  private_resolver_outbound_subnet   = local.enable_private_resolver ? module.network.subnets[var.private_resolver["outbound_subnet_name"]] : null

  ##################
  # Network Watcher
  ##################

  network_watcher_name = var.enable_network_watcher ? (
    var.network_watcher_name != null ? var.network_watcher_name : "network-watcher-${var.location}"
  ) : null

  create_network_watcher_resource_group = var.enable_network_watcher ? var.create_network_watcher_resource_group : false

  network_watcher_resource_group_name = local.create_network_watcher_resource_group ? (
    one(azurerm_resource_group.network_watcher[*].name)
    ) : (
    var.network_watcher_resource_group_name != null ? var.network_watcher_resource_group_name : azurerm_resource_group.main.name
  )

  ############
  # Flow Log
  ############

  create_flow_log_storage_account = var.flow_log != null ? var.flow_log.storage_account_name != null : false
  flow_log_sa_id                  = local.create_flow_log_storage_account ? azurerm_storage_account.flow_log_sa[0].id : try(var.flow_log.storage_account_id, "")

  create_flow_log_log_analytics_workspace = var.flow_log != null ? var.flow_log.log_analytics_workspace_name != null : false

  flow_log_workspace_id = local.create_flow_log_log_analytics_workspace ? azurerm_log_analytics_workspace.flow_log_law[0].workspace_id : try(var.flow_log.workspace_id, null)

  flow_log_workspace_resource_id = local.create_flow_log_log_analytics_workspace ? azurerm_log_analytics_workspace.flow_log_law[0].id : try(var.flow_log.workspace_resource_id, null)

  ##################################
  # Subnets
  ##################################

  subnets = {
    for k, v in var.subnets
    : k => merge(v, {
      associate_rt   = v.associate_rt != null ? v.associate_rt : local.enable_firewall
      route_table_id = v.route_table_id != null ? v.route_table_id : one(module.route-table.route_table.id)
      prefix         = v.address_prefix
    })
  }

  subnet_assoc_network_security_group = [
    for k, s in var.subnets
    : module.network.subnets[k].id
    if s.associate_default_network_security_group
  ]

  subnet_assoc_route_table = [
    for k, s in var.subnets
    : module.network.subnets[k].id
    if s.associate_default_route_table
  ]
}
