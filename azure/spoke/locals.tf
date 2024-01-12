locals {
  subnet_assoc_network_security_group = [
    for k, s in var.subnets
    : azurerm_subnet.main[k].id
    if s.associate_default_network_security_group == true
  ]

  subnet_assoc_route_table = [
    for k, s in var.subnets
    : azurerm_subnet.main[k].id
    if s.associate_default_route_table == true
  ]

  network_watcher_resource_group_name = var.network_watcher_resource_group != null ? var.network_watcher_resource_group : var.resource_group_name

  flow_log_sa_id = var.create_flow_log_storage_account == true ? azurerm_storage_account.flow_log_sa[0].id : var.flow_log_config.storage_account_id

  flow_log_workspace_id          = var.create_flow_log_log_analytics_workspace == true ? azurerm_log_analytics_workspace.flow_log_law[0].workspace_id : var.flow_log_config.workspace_id
  flow_log_workspace_resource_id = var.create_flow_log_log_analytics_workspace == true ? azurerm_log_analytics_workspace.flow_log_law[0].id : var.flow_log_config.workspace_resource_id
}