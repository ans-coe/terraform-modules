locals {
  tenant_id                  = var.tenant_id != null ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  log_analytics_workspace_id = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.main[0].id
}