# Terraform Module - Azure - Linux Function App

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This Terraform configuration will create a Linux function app using a container for its runtime. It is able to utilize a subnet optionally and enables the usage of identities.

Once deployed, management is expected to be through another medium, so changes to the application stack will be ignored.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the function app. | `string` | n/a | yes |
| <a name="input_allowed_frontdoor_ids"></a> [allowed\_frontdoor\_ids](#input\_allowed\_frontdoor\_ids) | A list of allowed frontdoor IDs. | `list(string)` | `[]` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | A list of allowed CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_ips"></a> [allowed\_scm\_ips](#input\_allowed\_scm\_ips) | A list of SCM allowed CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_service_tags"></a> [allowed\_scm\_service\_tags](#input\_allowed\_scm\_service\_tags) | A list of SCM allowed service tags. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_subnet_ids"></a> [allowed\_scm\_subnet\_ids](#input\_allowed\_scm\_subnet\_ids) | A list of SCM allowed subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_allowed_service_tags"></a> [allowed\_service\_tags](#input\_allowed\_service\_tags) | A list of allowed service tags. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | A list of allowed subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | A map of app settings. | `map(string)` | `{}` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | A map detailing the application stack. | `map(string)` | <pre>{<br>  "python_version": "3.10"<br>}</pre> | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | A list of connection string objects. | <pre>list(object({<br>    name  = string<br>    type  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | Cross origin resource sharing configuration. | <pre>object({<br>    allowed_origins     = list(string)<br>    support_credentials = optional(bool, null)<br>  })</pre> | `null` | no |
| <a name="input_daily_memory_time_quota_gs"></a> [daily\_memory\_time\_quota\_gs](#input\_daily\_memory\_time\_quota\_gs) | Daily memory time quota in gigabyte-seconds. | `string` | `null` | no |
| <a name="input_functions_extension_version"></a> [functions\_extension\_version](#input\_functions\_extension\_version) | Functions extension version to use on this function app. | `string` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | A list of user identity IDs to use for the function app. | `list(string)` | `[]` | no |
| <a name="input_key_vault_identity_id"></a> [key\_vault\_identity\_id](#input\_key\_vault\_identity\_id) | The user managed identity used for key vault. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Object detailing the plan, if creating one with this module. | <pre>object({<br>    create         = optional(bool, true)<br>    id             = optional(string)<br>    name           = optional(string)<br>    sku_name       = optional(string, "Y1")<br>    zone_balancing = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Enables shared access key within the storage account | `bool` | `false` | no |
| <a name="input_site_config"></a> [site\_config](#input\_site\_config) | A map with site config values. | `map(any)` | `{}` | no |
| <a name="input_sticky_app_settings"></a> [sticky\_app\_settings](#input\_sticky\_app\_settings) | A list of sticky app\_setting values. | `list(string)` | `[]` | no |
| <a name="input_sticky_connection_strings"></a> [sticky\_connection\_strings](#input\_sticky\_connection\_strings) | A list of sticky connection\_strings values. | `list(string)` | `[]` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the function app's backing storage account. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet to deploy this function app to. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | ID of the service plan. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Default FQDN of the function app. |
| <a name="output_id"></a> [id](#output\_id) | ID of the function app. |
| <a name="output_identity"></a> [identity](#output\_identity) | Identity of the function app. |
| <a name="output_location"></a> [location](#output\_location) | Location of the function app. |
| <a name="output_name"></a> [name](#output\_name) | Name  of the function app. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.main_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
