locals {
  log_analytics_id = var.use_log_analytics && var.log_analytics_id == null ? one(azurerm_log_analytics_workspace.main).id : var.log_analytics_id
}
