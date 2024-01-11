##########################
# Log Analytics Workspace
##########################

resource "azurerm_log_analytics_workspace" "main" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name
  retention_in_days   = var.log_analytics_workspace_retention
  sku                 = var.log_analytics_workspace_sku

  lifecycle {  
    precondition {  
      condition = (var.log_analytics_workspace_id == null) != (var.log_analytics_workspace_name == null)
      error_message = "Either log_analytics_workspace_id OR log_analytics_workspace_name must be specificed."  
    }  
  }  
}

###########
# Sentinel
###########

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id                 = local.log_analytics_workspace_id
  customer_managed_key_enabled = var.customer_managed_key_enabled
}

##################
# Data Connectors
##################

resource "azurerm_sentinel_data_connector_azure_active_directory" "main" {
  count                      = var.dc_ad_enabled ? 1 : 0
  name                       = "Azure Active Directory"
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tenant_id                  = local.tenant_id
}

resource "azurerm_sentinel_data_connector_azure_security_center" "main" {
  count                      = var.dc_security_center_enabled ? 1 : 0
  name                       = "Azure Security Center"
  log_analytics_workspace_id = local.log_analytics_workspace_id
}

resource "azurerm_sentinel_data_connector_azure_advanced_threat_protection" "main" {
  count                      = var.dc_advanced_threat_protection_enabled ? 1 : 0
  name                       = "Azure Active Directory Identity Protection"
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tenant_id                  = local.tenant_id
}

resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "main" {
  count                      = var.dc_microsoft_cloud_app_security_enabled ? 1 : 0
  name                       = "Microsoft 365 Defender"
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tenant_id                  = local.tenant_id
  discovery_logs_enabled     = var.cloud_app_security_config.discovery_logs_enabled
  alerts_enabled             = var.cloud_app_security_config.alerts_enabled
}

resource "azurerm_sentinel_data_connector_office_365" "main" {
  count                      = var.dc_office_365_enabled ? 1 : 0
  name                       = "Office 365"
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tenant_id                  = local.tenant_id
  exchange_enabled           = var.office_365_config.exchange_enabled
  sharepoint_enabled         = var.office_365_config.sharepoint_enabled
  teams_enabled              = var.office_365_config.teams_enabled
}

resource "azurerm_sentinel_data_connector_microsoft_threat_intelligence" "main" {
  count                                        = var.dc_microsoft_threat_intelligence_enabled ? 1 : 0
  name                                         = "Microsoft Threat Intelligence"
  log_analytics_workspace_id                   = local.log_analytics_workspace_id
  tenant_id                                    = local.tenant_id
  microsoft_emerging_threat_feed_lookback_date = var.microsoft_threat_intelligence_feed_lookback_date
}

resource "azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection" "main" {
  count                      = var.dc_microsoft_defender_advanced_threat_protection_enabled ? 1 : 0
  name                       = "Microsoft Defender Advanced Threat Protection"
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tenant_id                  = local.tenant_id
}

resource "azurerm_sentinel_data_connector_microsoft_threat_protection" "main" {
  count                      = var.dc_microsoft_threat_protection_enabled ? 1 : 0
  name                       = "Microsoft Threat Protection"
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tenant_id                  = local.tenant_id
}