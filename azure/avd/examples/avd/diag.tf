module "log_analytics" {
  source              = "../../modules/log-analytics"
  workspace_name      = ""
  resource_group_name = ""
  location            = var.location

  ## tags ##
  application         = "log"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}

module "diagnostics_external_parties_hostpool" {

  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.external-parties-hostpool.avd_host_pool_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.external-parties-hostpool.avd_host_pool_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_external_parties_validation_hostpool" {

  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.external-parties-validation-hostpool.avd_host_pool_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.external-parties-validation-hostpool.avd_host_pool_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_external_parties_workspace" {
  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.external-parties-workspace.Workspace_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.external-parties-hostpool.avd_host_pool_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_external_parties_validation_workspace" {
  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.external-parties-validation-workspace.Workspace_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.external-parties-validation-workspace.workspace_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_edge_app_group" {
  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.microsoft-edge-application-group.app_group_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.microsoft-edge-application-group.app_group_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_sql_app_group" {
  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.sql-server-management-studio-application-group.app_group_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.sql-server-management-studio-application-group.app_group_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_cli_app_group" {
  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.azure-cli-application-group.app_group_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.azure-cli-application-group.app_group_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_vscode_app_group" {
  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.visual-studio-code-application-group.app_group_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.visual-studio-code-application-group.app_group_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}

module "diagnostics_jetbrains_app_group" {
  source                     = "../../modules/diagnostic-settings"
  diag_name                  = module.jetbrains-ide-application-group.app_group_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
  resource_id                = module.jetbrains-ide-application-group.app_group_id
  logs_destinations_ids      = ["Log Analytics Workspace"]
}
