<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.68.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Application type, values can be App Attach, External Parties, Microsoft Edge. ETC | `string` | n/a | yes |
| <a name="input_charge_code"></a> [charge\_code](#input\_charge\_code) | Project charge code | `string` | n/a | yes |
| <a name="input_criticality"></a> [criticality](#input\_criticality) | Project criticality | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | Data Classification | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Project environment | `string` | n/a | yes |
| <a name="input_lbsPatchDefinitions"></a> [lbsPatchDefinitions](#input\_lbsPatchDefinitions) | LBS Patch Definitions | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location to create the resources in. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to create the resources in. | `string` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | The name of this Log Analytics workspace. | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_diagnostic_setting_enabled_log_categories"></a> [diagnostic\_setting\_enabled\_log\_categories](#input\_diagnostic\_setting\_enabled\_log\_categories) | A list of log categories to be enabled for this diagnostic setting. | `list(string)` | <pre>[<br>  "Audit"<br>]</pre> | no |
| <a name="input_diagnostic_setting_enabled_metric_categories"></a> [diagnostic\_setting\_enabled\_metric\_categories](#input\_diagnostic\_setting\_enabled\_metric\_categories) | A list of metric categories to be enabled for this diagnostic setting. | `list(string)` | `[]` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | Should local authentication using shared key be disabled for this Log Analytics workspace? If value is true, Microsoft Entra authentication must be used instead. | `bool` | `true` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The number of days that logs should be retained. | `number` | `90` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | The primary shared key of this Log Analytics workspace. |
| <a name="output_secondary_shared_key"></a> [secondary\_shared\_key](#output\_secondary\_shared\_key) | The secondary shared key of this Log Analytics workspace. |
| <a name="output_workspace_customer_id"></a> [workspace\_customer\_id](#output\_workspace\_customer\_id) | The workspace (customer) ID of this Log Analytics workspace. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The ID of this Log Analytics workspace. |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | The name of this Log Analytics workspace. |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->