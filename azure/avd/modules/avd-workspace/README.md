<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.47 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.68.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Application type, values can be App Attach, External Parties, Microsoft Edge. ETC | `string` | n/a | yes |
| <a name="input_avd_workspace_name"></a> [avd\_workspace\_name](#input\_avd\_workspace\_name) | value | `string` | n/a | yes |
| <a name="input_charge_code"></a> [charge\_code](#input\_charge\_code) | Project charge code | `string` | n/a | yes |
| <a name="input_criticality"></a> [criticality](#input\_criticality) | Project criticality | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | Data Classification | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Project environment | `string` | n/a | yes |
| <a name="input_lbsPatchDefinitions"></a> [lbsPatchDefinitions](#input\_lbsPatchDefinitions) | LBS Patch Definitions | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region to use. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| <a name="input_workspace_config"></a> [workspace\_config](#input\_workspace\_config) | AVD Workspace specific configuration. | <pre>object({<br>    friendly_name                 = optional(string)<br>    description                   = optional(string)<br>    public_network_access_enabled = optional(bool)<br>    extra_tags                    = optional(map(string))<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Workspace_name"></a> [Workspace\_name](#output\_Workspace\_name) | Host pool ID |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Host pool ID |

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_desktop_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->