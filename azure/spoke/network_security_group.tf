#########################
# Network Security Group
#########################

# Conditions for Route Table Association:
# If var.subnet[].associate_default_network_security_group == true then the default nsg is associated with the subnet.

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


  # flow_log_config = var.flow_log_config != null ? merge(
  #   {
  #     name = ""
  #     storage_account_id = ""
  #   },
  #   var.flow_log_config,
  #   {
  #   network_watcher_name                = local.network_watcher_name
  #   network_watcher_resource_group_name = local.network_watcher_resource_group_name
  #   }
  # ) : null

  enable_flow_log = var.flow_log_config != null
  flow_log_config = var.flow_log_config != null ? {
    name                                = lookup(var.flow_log_config, "name", "") // using lookup to satisfy nsg module requirement
    storage_account_id                  = local.create_flow_log_storage_account ? azurerm_storage_account.flow_log_sa[0].id : lookup(var.flow_log_config, "storage_account_id", "") // using lookup to satisfy nsg module requirement
    network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "network-watcher-${var.location}"
    network_watcher_resource_group_name = var.network_watcher_resource_group_name != null ? var.network_watcher_resource_group_name : var.resource_group_name
    retention_days                      = var.flow_log_config.retention_days
    enable_analytics                    = var.flow_log_config.enable_analytics
    analytics_interval_minutes          = var.flow_log_config.analytics_interval_minutes
    workspace_id                        = local.flow_log_workspace_id
    workspace_region                    = var.location
    workspace_resource_id               = local.flow_log_workspace_resource_id
  } : null

}


###########################
# Flow Log Storage Account
###########################

resource "azurerm_storage_account" "flow_log_sa" {
  count = var.create_flow_log_storage_account ? 1 : 0

  name                = var.flow_log_config.storage_account_name != null ? var.flow_log_config.storage_account_name : "fl-sa-${module.network_security_group.name}"
  location            = var.location
  resource_group_name = local.network_watcher_resource_group_name
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    precondition {
      condition     = (var.flow_log_config.storage_account_name == null) != (var.flow_log_config.storage_account_id == null)
      error_message = "Either storage_account_name OR storage_account_id must be specificed."
    }
  }
}

###############
# Flow Log LAW
###############

resource "azurerm_log_analytics_workspace" "flow_log_law" {
  count = var.create_flow_log_log_analytics_workspace ? 1 : 0

  name                = var.flow_log_config.log_analytics_workspace_name != null ? var.flow_log_config.log_analytics_workspace_name : "fl-law-${module.network_security_group.name}"
  location            = var.location
  resource_group_name = local.network_watcher_resource_group_name
  tags                = var.tags

  retention_in_days = 30
  daily_quota_gb    = 1

  lifecycle {
    precondition {
      condition     = (var.flow_log_config.log_analytics_workspace_name == null) != ((var.flow_log_config.workspace_resource_id == null) && (var.flow_log_config.workspace_id == null))
      error_message = "Either log_analytics_workspace_name workspace_resource_id AND workspace_id must be specificed."
    }
  }
}