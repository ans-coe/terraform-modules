# Terraform Module - Required Tags

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module will implement policies to ensure that resources have required tags.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name of the policy. | `string` | `"Required Tags"` | no |
| <a name="input_enforce"></a> [enforce](#input\_enforce) | Controls the enforcement of the policy. | `bool` | `false` | no |
| <a name="input_exclude_scopes"></a> [exclude\_scopes](#input\_exclude\_scopes) | Target scopes that are excluded from the policy assignment. Only affects management group and subscription scopes. | `list(string)` | `[]` | no |
| <a name="input_management_group_id"></a> [management\_group\_id](#input\_management\_group\_id) | The management group ID to use when creating this policy definition. If blank, applies to target subscription. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the policy. | `string` | `"required_tags"` | no |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | The scopes that the policy will be assigned to. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The key of each tag that will be configured for policy. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the policy set definition. |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group_policy_assignment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_policy_set_definition.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition) | resource |
| [azurerm_resource_group_policy_assignment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_policy_definition.tag_resource_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.tag_resources](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
