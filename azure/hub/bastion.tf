module "bastion" {
  count  = local.enable_bastion ? 1 : 0
  source = "git::https://github.com/ans-coe/terraform-modules.git//azure/bastion/?ref=a63e6c9eb16019abd462e1b2843e24fb1b76169c"

  name                = var.bastion_config["name"]
  location            = var.location
  resource_group_name = var.bastion_config["resource_group_name"] != "" ? var.bastion_config["resource_group_name"] : var.resource_group_name
  tags                = var.tags

  subnet_id                   = local.bastion_subnet.id
  public_ip_name              = var.bastion_config["public_ip_name"]
  network_security_group_name = var.bastion_config["network_security_group_name"]
  whitelist                   = var.bastion_config["whitelist_cidrs"]
}

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  count = local.enable_bastion && var.log_analytics_workspace_id != null ? 1 : 0

  name                       = format("diag-%s", var.bastion_config["name"])
  target_resource_id         = module.bastion[count.index].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"

    retention_policy {
      days    = 30
      enabled = true
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}