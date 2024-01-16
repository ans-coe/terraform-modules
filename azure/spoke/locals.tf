locals {

  ##################################
  # Subnet > RT and NSG Association
  ##################################

  subnet_assoc_network_security_group = [
    for k, s in var.subnets
    : azurerm_subnet.main[k].id
    if s.associate_default_network_security_group
  ]

  subnet_assoc_route_table = [
    for k, s in var.subnets
    : azurerm_subnet.main[k].id
    if s.associate_default_route_table
  ]

  ##################
  # Network Watcher
  ##################

  network_watcher_name = var.enable_network_watcher ? (
    var.network_watcher_name != null ? var.network_watcher_name : "network-watcher-${var.location}"
  ) : null

  network_watcher_resource_group_name = var.enable_network_watcher ? (
    var.network_watcher_resource_group_name != null ? var.network_watcher_resource_group_name : var.resource_group_name
  ) : null

  ############
  # Flow Log
  ############

  create_flow_log_storage_account = var.flow_log_config != null ? var.flow_log_config.storage_account_name != null : false
  flow_log_sa_id                  = local.create_flow_log_storage_account ? azurerm_storage_account.flow_log_sa[0].id : try(var.flow_log_config.storage_account_id, "")

  create_flow_log_log_analytics_workspace = var.flow_log_config != null ? var.flow_log_config.log_analytics_workspace_name != null : false

  flow_log_workspace_id = local.create_flow_log_log_analytics_workspace ? azurerm_log_analytics_workspace.flow_log_law[0].workspace_id : try(var.flow_log_config.workspace_id, null)

  flow_log_workspace_resource_id = local.create_flow_log_log_analytics_workspace ? azurerm_log_analytics_workspace.flow_log_law[0].id : try(var.flow_log_config.workspace_resource_id, null)
}