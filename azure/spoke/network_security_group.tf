#########################
# Network Security Group
#########################

# Conditions for Network Security Group Association:
# If var.subnet[].associate_default_network_security_group == true then the default nsg is associated with the subnet.
# 
# Conditions for Flow Log
# If var.flow_log_config is set and var.flow_log_config.storage_account_name is specified, a storage account is created. 
#   If var.flow_log_config.storage_account_name is not specified, storage_account_id must be given.
#
# If var.flow_log_config is set AND var.flow_log_config.log_analytics_workspace_name is set, a Log Analytics Workspace is created
#   If var.flow_log_config.log_analytics_workspace_name is not specified, workspace_id and workspace_resource_id must be given. 

module "network_security_group" {
  count  = var.create_default_network_security_group ? 1 : 0
  source = "../network-security-group"

  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  subnet_ids = local.subnet_assoc_network_security_group

  rules_inbound  = var.nsg_rules_inbound
  rules_outbound = var.nsg_rules_outbound

  enable_flow_log = var.flow_log_config != null
  flow_log_config = var.flow_log_config != null ? {
    name                                = try(var.flow_log_config.name, "")
    storage_account_id                  = local.flow_log_sa_id
    network_watcher_name                = local.network_watcher_name
    network_watcher_resource_group_name = local.network_watcher_resource_group_name

    retention_days             = var.flow_log_config.retention_days
    enable_analytics           = var.flow_log_config.enable_analytics
    analytics_interval_minutes = var.flow_log_config.analytics_interval_minutes
    workspace_id               = local.flow_log_workspace_id
    workspace_region           = var.location
    workspace_resource_id      = local.flow_log_workspace_resource_id
  } : null
}


###########################
# Flow Log Storage Account
###########################

resource "azurerm_storage_account" "flow_log_sa" {
  count = local.create_flow_log_storage_account ? 1 : 0

  name                = var.flow_log_config.storage_account_name != null ? var.flow_log_config.storage_account_name : lower(replace("${module.network_security_group.name}flsa1", "/[-_]/", ""))
  location            = var.location
  resource_group_name = local.network_watcher_resource_group_name
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

###############
# Flow Log LAW
###############

resource "azurerm_log_analytics_workspace" "flow_log_law" {
  count = local.create_flow_log_log_analytics_workspace ? 1 : 0

  name                = var.flow_log_config.log_analytics_workspace_name
  location            = var.location
  resource_group_name = local.network_watcher_resource_group_name
  tags                = var.tags

  retention_in_days = 30
  daily_quota_gb    = 1
}