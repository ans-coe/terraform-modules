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
| <a name="input_avd_scaling_plan_name"></a> [avd\_scaling\_plan\_name](#input\_avd\_scaling\_plan\_name) | value | `string` | n/a | yes |
| <a name="input_charge_code"></a> [charge\_code](#input\_charge\_code) | Project charge code | `string` | n/a | yes |
| <a name="input_criticality"></a> [criticality](#input\_criticality) | Project criticality | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | Data Classification | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Project environment | `string` | n/a | yes |
| <a name="input_hostpool_id"></a> [hostpool\_id](#input\_hostpool\_id) | The ID of the HostPool to assign the Scaling Plan to | `string` | n/a | yes |
| <a name="input_lbsPatchDefinitions"></a> [lbsPatchDefinitions](#input\_lbsPatchDefinitions) | LBS Patch Definitions | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region to use. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| <a name="input_scaling_plan_config"></a> [scaling\_plan\_config](#input\_scaling\_plan\_config) | AVD Scaling Plan specific configuration. | <pre>object({<br>    enabled       = optional(bool, false)<br>    friendly_name = optional(string)<br>    description   = optional(string)<br>    exclusion_tag = optional(string)<br>    timezone      = optional(string, "UTC") # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/<br>    schedules = optional(list(object({<br>      name                                 = string<br>      days_of_week                         = list(string)<br>      peak_start_time                      = string<br>      peak_load_balancing_algorithm        = optional(string, "BreadthFirst")<br>      off_peak_start_time                  = string<br>      off_peak_load_balancing_algorithm    = optional(string, "DepthFirst")<br>      ramp_up_start_time                   = string<br>      ramp_up_load_balancing_algorithm     = optional(string, "BreadthFirst")<br>      ramp_up_capacity_threshold_percent   = optional(number, 75)<br>      ramp_up_minimum_hosts_percent        = optional(number, 33)<br>      ramp_down_start_time                 = string<br>      ramp_down_capacity_threshold_percent = optional(number, 5)<br>      ramp_down_force_logoff_users         = optional(string, false)<br>      ramp_down_load_balancing_algorithm   = optional(string, "DepthFirst")<br>      ramp_down_minimum_hosts_percent      = optional(number, 33)<br>      ramp_down_notification_message       = optional(string, "Please log off in the next 45 minutes...")<br>      ramp_down_stop_hosts_when            = optional(string, "ZeroSessions")<br>      ramp_down_wait_time_minutes          = optional(number, 45)<br>    })), [])<br>    role_assignment = optional(object({<br>      enabled   = optional(bool, false)<br>      object_id = optional(string)<br>    }), {})<br>    extra_tags = optional(map(string))<br>  })</pre> | `{}` | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_definition.scaling_role_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_virtual_desktop_scaling_plan.scaling_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_scaling_plan) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->