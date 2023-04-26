# Terraform Module - Azure - Windows Web App

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This Terraform configuration will create a Windows web app. It is able to utilize a subnet optionally and enables the usage of identities.

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
| <a name="input_name"></a> [name](#input\_name) | The name of the app service. | `string` | n/a | yes |
| <a name="input_allowed_frontdoor_ids"></a> [allowed\_frontdoor\_ids](#input\_allowed\_frontdoor\_ids) | A list of allowed frontdoor IDs. | `list(string)` | `[]` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | A list of allowed CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_ips"></a> [allowed\_scm\_ips](#input\_allowed\_scm\_ips) | A list of SCM allowed CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_service_tags"></a> [allowed\_scm\_service\_tags](#input\_allowed\_scm\_service\_tags) | A list of SCM allowed service tags. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_subnet_ids"></a> [allowed\_scm\_subnet\_ids](#input\_allowed\_scm\_subnet\_ids) | A list of SCM allowed subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_allowed_service_tags"></a> [allowed\_service\_tags](#input\_allowed\_service\_tags) | A list of allowed service tags. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | A list of allowed subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | A map of app settings. | `map(string)` | `{}` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | A map detailing the application stack. | `map(string)` | <pre>{<br>  "docker_container_name": "azure-app-service/samples/aspnethelloworld",<br>  "docker_container_registry": "mcr.microsoft.com",<br>  "docker_container_tag": "latest"<br>}</pre> | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | A list of connection string objects. | <pre>list(object({<br>    name  = string<br>    type  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | Cross origin resource sharing configuration. | <pre>object({<br>    allowed_origins     = list(string)<br>    support_credentials = optional(bool, null)<br>  })</pre> | `null` | no |
| <a name="input_create_application_insights"></a> [create\_application\_insights](#input\_create\_application\_insights) | Create an instance of Log Analytics and Application Insights for the app service. | `bool` | `true` | no |
| <a name="input_default_documents"></a> [default\_documents](#input\_default\_documents) | A list of strings for default documents. | `list(string)` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | A list of user identity IDs to use for the app service. | `list(string)` | `[]` | no |
| <a name="input_key_vault_identity_id"></a> [key\_vault\_identity\_id](#input\_key\_vault\_identity\_id) | The user managed identity used for key vault. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_logs"></a> [logs](#input\_logs) | The log configuration to use with this app service. | <pre>object({<br>    level                   = optional(string, "Warning")<br>    detailed_error_messages = optional(bool, false)<br>    failed_request_tracing  = optional(bool, false)<br>    retention_in_days       = optional(number, 7)<br>    retention_in_mb         = optional(number, 100)<br>  })</pre> | `{}` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Object detailing the plan, if creating one with this module. | <pre>object({<br>    create         = optional(bool, true)<br>    id             = optional(string)<br>    name           = optional(string)<br>    sku_name       = optional(string, "B1")<br>    zone_balancing = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_site_config"></a> [site\_config](#input\_site\_config) | A map with site config values. | `map(any)` | `{}` | no |
| <a name="input_slots"></a> [slots](#input\_slots) | Names for slots that are clones of the app. | `set(string)` | `[]` | no |
| <a name="input_sticky_app_settings"></a> [sticky\_app\_settings](#input\_sticky\_app\_settings) | A list of sticky app\_setting values. | `list(string)` | `[]` | no |
| <a name="input_sticky_connection_strings"></a> [sticky\_connection\_strings](#input\_sticky\_connection\_strings) | A list of sticky connection\_strings values. | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet to deploy this app service to. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_virtual_application"></a> [virtual\_application](#input\_virtual\_application) | Virtual application configuration for the app service. | <pre>object({<br>    physical_path = optional(string, "site\\wwwroot")<br>    preload       = optional(bool, false)<br>    virtual_path  = optional(string, "/")<br>    virtual_directories = optional(list(object({<br>      physical_path = string<br>      virtual_path  = string<br>    })), [])<br>  })</pre> | `{}` | no |
| <a name="input_zip_deploy_file"></a> [zip\_deploy\_file](#input\_zip\_deploy\_file) | Path to a zip file to deploy to the app service. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service"></a> [app\_service](#output\_app\_service) | Output containing the main app service. |
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | ID of the service plan. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Default FQDN of the app service. |
| <a name="output_id"></a> [id](#output\_id) | ID of the app service. |
| <a name="output_identity"></a> [identity](#output\_identity) | Identity of the app service. |
| <a name="output_location"></a> [location](#output\_location) | Location of the app service. |
| <a name="output_name"></a> [name](#output\_name) | Name of the app service. |
| <a name="output_slots"></a> [slots](#output\_slots) | Object containing details for the created slots. |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_windows_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) | resource |
| [azurerm_windows_web_app_slot.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app_slot) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
