#################
# Resource Group
#################

resource "azurerm_resource_group" "bastion" {
  count = var.bastion_config.resource_group_name != null ? 1 : 0

  name     = var.bastion_config.resource_group_name
  location = var.location
  tags     = var.tags
}

##########
# Bastion
##########

module "bastion" {
  count  = local.enable_bastion ? 1 : 0
  source = "../bastion"

  name                = var.bastion_config["name"]
  location            = var.location
  resource_group_name = local.bastion_resource_group_name
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

    ## Removing depreciated retention_policy, retention should be set in the log_analytics_workspace
    ## Leaving this comment in for explaination reasons
    # retention_policy {
    #   days    = 30
    #   enabled = true
    # }
  }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}