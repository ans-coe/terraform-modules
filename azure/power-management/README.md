# Terraform Module - Azure - Power Management

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This Terraform configuration will create automation resources to assist with power management. This will come with scripts for powering resources on and off, and allow for schedules to be created with the storage account. It will also have a custom role that will be assigned to target resources, limiting access specifically to the main functions of the automation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_log_progress"></a> [log\_progress](#input\_log\_progress) | Enable progress logging. | `bool` | `false` | no |
| <a name="input_log_verbose"></a> [log\_verbose](#input\_log\_verbose) | Enable verbose logging. | `bool` | `false` | no |
| <a name="input_managed_subscription_ids"></a> [managed\_subscription\_ids](#input\_managed\_subscription\_ids) | A list of subscription IDs that will be managed by this module. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Power Management Automation Account. | `string` | `"power-management-aa"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_scheduled_hours"></a> [scheduled\_hours](#input\_scheduled\_hours) | A list of scheduled hours in 24h format to create for weekdays. | `list(string)` | <pre>[<br>  "0830",<br>  "1800"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The timezone used for the created schedules. | `string` | `"Etc/UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the automation account. |
| <a name="output_identity"></a> [identity](#output\_identity) | The automation account identity. |
| <a name="output_location"></a> [location](#output\_location) | Location of the automation account. |
| <a name="output_main_runbooks"></a> [main\_runbooks](#output\_main\_runbooks) | Name of the main power management runbook. |
| <a name="output_name"></a> [name](#output\_name) | Name of the automation account. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |
| <a name="output_schedules"></a> [schedules](#output\_schedules) | Output of created weekdays schedules. |

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_automation_runbook.power_management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.weekdays](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.power_management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.power_management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |