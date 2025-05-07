<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
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
| <a name="input_location"></a> [location](#input\_location) | Azure region to use | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | Specifies the Level to be used for this RG Lock. Possible values are Empty (no lock), CanNotDelete and ReadOnly. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group generated id |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | Resource group location (region) |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.resource_group_level_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->