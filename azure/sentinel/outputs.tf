output "log_analytics_workspace_id" {
  value = local.log_analytics_workspace_id
}

output "azure_sentinel_id" {
  value = join("", azurerm_sentinel_log_analytics_workspace_onboarding.main.*.id)
}

output "dc_ad_id" {
  value = join("", azurerm_sentinel_data_connector_azure_active_directory.main.*.id)
}

output "dc_security_center_id" {
  value = join("", azurerm_sentinel_data_connector_azure_security_center.main.*.id)
}

output "dc_advanced_threat_protection_id" {
  value = join("", azurerm_sentinel_data_connector_azure_advanced_threat_protection.main.*.id)
}

output "dc_microsoft_cloud_app_security_id" {
  value = join("", azurerm_sentinel_data_connector_microsoft_cloud_app_security.main.*.id)
}

output "dc_office_365_id" {
  value = join("", azurerm_sentinel_data_connector_office_365.main.*.id)
}

output "dc_microsoft_threat_intelligence_id" {
  value = join("", azurerm_sentinel_data_connector_microsoft_threat_intelligence.main.*.id)
}

output "dc_microsoft_defender_advanced_threat_protection_id" {
  value = join("", azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection.main.*.tenant_id)
}

output "dc_microsoft_threat_protection_id" {
  value = join("", azurerm_sentinel_data_connector_microsoft_threat_protection.main.*.id)
}