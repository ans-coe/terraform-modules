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
| <a name="input_avd_host_pool_name"></a> [avd\_host\_pool\_name](#input\_avd\_host\_pool\_name) | value | `string` | n/a | yes |
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
| <a name="input_host_pool_config"></a> [host\_pool\_config](#input\_host\_pool\_config) | AVD Host Pool specific configuration. | <pre>object({<br>    friendly_name                         = optional(string)<br>    description                           = optional(string)<br>    validate_environment                  = optional(bool, true)<br>    custom_rdp_properties                 = optional(string, "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1;")<br>    public_network_access                 = optional(string, "Enabled")<br>    type                                  = optional(string, "Pooled")<br>    load_balancer_type                    = optional(string, "BreadthFirst")<br>    personal_desktop_assignment_type      = optional(string, "Automatic")<br>    maximum_sessions_allowed              = optional(number, 16)<br>    preferred_app_group_type              = optional(string)<br>    start_vm_on_connect                   = optional(bool, false)<br>    host_registration_expires_in_in_hours = optional(number, 48)<br>    scheduled_agent_updates = optional(object({<br>      enabled                   = optional(bool, false)<br>      timezone                  = optional(string, "UTC") # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/<br>      use_session_host_timezone = optional(bool, false)<br>      schedules = optional(list(object({<br>        day_of_week = string<br>        hour_of_day = number<br>      })), [])<br>    }), {})<br>    extra_tags = optional(map(string))<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_avd_host_pool_id"></a> [avd\_host\_pool\_id](#output\_avd\_host\_pool\_id) | Host pool ID |
| <a name="output_avd_host_pool_name"></a> [avd\_host\_pool\_name](#output\_avd\_host\_pool\_name) | Host pool name |

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_desktop_host_pool.host_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool) | resource |
| [azurerm_virtual_desktop_host_pool_registration_info.host_pool_registration_info](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool_registration_info) | resource |
| [time_rotating.time](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->