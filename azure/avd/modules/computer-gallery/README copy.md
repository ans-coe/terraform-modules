<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region to use | `string` | `"UK South"` | no |

## Outputs

No outputs.

## Resources

No resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure-cli-application-group"></a> [azure-cli-application-group](#module\_azure-cli-application-group) | ../../modules/avd-app-group | n/a |
| <a name="module_diagnostics_app_group"></a> [diagnostics\_app\_group](#module\_diagnostics\_app\_group) | ../../modules/diagnostic-settings | n/a |
| <a name="module_diagnostics_host_pool"></a> [diagnostics\_host\_pool](#module\_diagnostics\_host\_pool) | ../../modules/diagnostic-settings | n/a |
| <a name="module_diagnostics_workspace"></a> [diagnostics\_workspace](#module\_diagnostics\_workspace) | ../../modules/diagnostic-settings | n/a |
| <a name="module_external-parties-hostpool"></a> [external-parties-hostpool](#module\_external-parties-hostpool) | ../../modules/avd-host-pool | n/a |
| <a name="module_external-parties-validation-hostpool"></a> [external-parties-validation-hostpool](#module\_external-parties-validation-hostpool) | ../../modules/avd-host-pool | n/a |
| <a name="module_external-parties-validation-workspace"></a> [external-parties-validation-workspace](#module\_external-parties-validation-workspace) | ../../modules/avd-workspace | n/a |
| <a name="module_external-parties-workspace"></a> [external-parties-workspace](#module\_external-parties-workspace) | ../../modules/avd-workspace | n/a |
| <a name="module_jetbrains-ide-application-group"></a> [jetbrains-ide-application-group](#module\_jetbrains-ide-application-group) | ../../modules/avd-app-group | n/a |
| <a name="module_log_analytics"></a> [log\_analytics](#module\_log\_analytics) | ../../modules/log-analytics | n/a |
| <a name="module_microsoft-edge-application-group"></a> [microsoft-edge-application-group](#module\_microsoft-edge-application-group) | ../../modules/avd-app-group | n/a |
| <a name="module_scaling_plan"></a> [scaling\_plan](#module\_scaling\_plan) | ../../modules/avd-auto-scaling | n/a |
| <a name="module_sql-server-management-studio-application-group"></a> [sql-server-management-studio-application-group](#module\_sql-server-management-studio-application-group) | ../../modules/avd-app-group | n/a |
| <a name="module_visual-studio-code-application-group"></a> [visual-studio-code-application-group](#module\_visual-studio-code-application-group) | ../../modules/avd-app-group | n/a |
<!-- END_TF_DOCS -->