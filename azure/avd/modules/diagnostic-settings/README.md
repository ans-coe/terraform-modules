<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.68.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_diag_name"></a> [diag\_name](#input\_diag\_name) | The name which should be used for this Log Analytics | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID | `string` | n/a | yes |
| <a name="input_logs_destinations_ids"></a> [logs\_destinations\_ids](#input\_logs\_destinations\_ids) | List of destination resources IDs for logs diagnostic destination.<br>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br>If you want to use Azure EventHub as destination, you must provide a formatted string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the <code>&#124;</code> character. | `list(string)` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | The ID of the resource on which activate the diagnostic settings. | `string` | n/a | yes |
| <a name="input_excluded_log_categories"></a> [excluded\_log\_categories](#input\_excluded\_log\_categories) | List of log categories to exclude. | `list(string)` | `[]` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | When set to 'Dedicated' logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table. | `string` | `"AzureDiagnostics"` | no |
| <a name="input_log_categories"></a> [log\_categories](#input\_log\_categories) | List of log categories. Defaults to all available. | `list(string)` | `null` | no |
| <a name="input_metric_categories"></a> [metric\_categories](#input\_metric\_categories) | List of metric categories. Defaults to all available. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_id"></a> [diagnostic\_settings\_id](#output\_diagnostic\_settings\_id) | ID of the Diagnostic Settings. |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_categories.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->