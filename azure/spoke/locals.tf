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

  network_watcher_name = var.enable_network_watcher ? (
    var.network_watcher_name != null ? var.network_watcher_name : "network-watcher-${var.location}"
  ) : null

  network_watcher_resource_group_name = var.enable_network_watcher ? (
    var.network_watcher_resource_group_name != null ? var.network_watcher_resource_group_name : var.resource_group_name
  ) : null

  flow_log_config = var.flow_log_config != null ? (
    merge(var.flow_log_config, {
    # name                                = var.flow_log_config.name
    network_watcher_name                = local.network_watcher_name
    network_watcher_resource_group_name = local.network_watcher_resource_group_name
    storage_account_id                  = local.flow_log_sa_id
    # retention_days                      = var.flow_log_config.retention_days

    # enable_analytics               = var.flow_log_config.enable_analytics
    # analytics_interval_minutes     = var.flow_log_config.analytics_interval_minutes
    workspace_id                   = local.flow_log_workspace_id
    # workspace_region               = var.location
    workspace_resource_id          = local.flow_log_workspace_resource_id
  })) : null

  flow_log_sa_id = var.flow_log_config != null ? (
    var.create_flow_log_storage_account == true ? azurerm_storage_account.flow_log_sa[0].id : var.flow_log_config.storage_account_id
  ) : null

  flow_log_workspace_id = var.flow_log_config != null ? (
    var.create_flow_log_log_analytics_workspace ? azurerm_log_analytics_workspace.flow_log_law[0].workspace_id : var.flow_log_config.workspace_id
  ) : null

  flow_log_workspace_resource_id = var.flow_log_config != null ? (
    var.create_flow_log_log_analytics_workspace == true ? azurerm_log_analytics_workspace.flow_log_law[0].id : var.flow_log_config.workspace_resource_id
  ) : null
}