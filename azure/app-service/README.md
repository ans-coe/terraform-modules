# Terraform Module - Azure - App Service

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This Terraform configuration will create an App Service of either "Windows" or "Linux". It is able to utilize a subnet optionally and enables the usage of identities.

Once deployed, management is expected to be through another medium, so changes to the application stack will be ignored.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.79 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the app service. | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Windows or Linux Web App | `string` | n/a | yes |
| <a name="input_allowed_frontdoor_ids"></a> [allowed\_frontdoor\_ids](#input\_allowed\_frontdoor\_ids) | A list of allowed frontdoor IDs. | `list(string)` | `[]` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | A list of allowed CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_ips"></a> [allowed\_scm\_ips](#input\_allowed\_scm\_ips) | A list of SCM allowed CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_service_tags"></a> [allowed\_scm\_service\_tags](#input\_allowed\_scm\_service\_tags) | A list of SCM allowed service tags. | `list(string)` | `[]` | no |
| <a name="input_allowed_scm_subnet_ids"></a> [allowed\_scm\_subnet\_ids](#input\_allowed\_scm\_subnet\_ids) | A list of SCM allowed subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_allowed_service_tags"></a> [allowed\_service\_tags](#input\_allowed\_service\_tags) | A list of allowed service tags. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | A list of allowed subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | A map of app settings. | `map(string)` | `{}` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | A map detailing the application stack. | <pre>object({<br>    docker_image_name        = optional(string)<br>    docker_registry_url      = optional(string)<br>    docker_registry_username = optional(string)<br>    docker_registry_password = optional(string)<br>    dotnet_version           = optional(string)<br>    java_version             = optional(string)<br>    node_version             = optional(string)<br>    php_version              = optional(string)<br><br>    ## Windows Only<br>    current_stack                = optional(string)<br>    dotnet_core_version          = optional(string)<br>    tomcat_version               = optional(string)<br>    java_embedded_server_enabled = optional(bool)<br>    python                       = optional(bool)<br><br>    ## Linux Only<br>    go_version          = optional(string)<br>    java_server         = optional(string)<br>    java_server_version = optional(string)<br>    python_version      = optional(string)<br>    ruby_version        = optional(string)<br>  })</pre> | <pre>{<br>  "docker_image_name": "azure-app-service/samples/aspnethelloworld:latest",<br>  "docker_registry_url": "mcr.microsoft.com"<br>}</pre> | no |
| <a name="input_autoscaling"></a> [autoscaling](#input\_autoscaling) | Basic implementation of a CPU autoscaler | <pre>object({<br>    capacity = optional(object({<br>      minimum = optional(number, 1)<br>      maximum = optional(number, 3)<br>      default = optional(number, 1)<br>    }), {})<br>    cpu_greater_than = optional(number, 50) // CPU percentage to scale up on<br>    cpu_less_than    = optional(number, 15) // CPU percentage to scale down on<br>  })</pre> | `null` | no |
| <a name="input_cert_options"></a> [cert\_options](#input\_cert\_options) | Options related to the certificate | <pre>object({<br>    use_managed_certificate = optional(bool, true)<br>    pfx_blob                = optional(string)<br>    password                = optional(string)<br>    // Setting Keyvault to empty map will cause the creation of Keyvault with default name and example cert<br>    key_vault = optional(object({<br>      certificate_name      = string           // Use this value to set the name of the certificate<br>      key_vault_custom_name = optional(string) // If you wanted to name the keyvault something different to the default.<br>      key_vault_secret_id   = optional(string) // If the cert already exists, it can be provided here<br>    }))<br>    // To-Do Validation = key_vault or pfx_blob must be set but not both. <br>    // To-Do Validation = certificate_name = 1-127 character string, starting with a letter and containing only 0-9, a-z, A-Z, and - (if not null)<br>    // To-Do Validation = if key_vault_secret_id is set key_vault_custom_name is ignored and should be null because a keyvault is not created.<br>    // To-Do Validation = to specify cert options, custom domain must be set.<br>  })</pre> | `null` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | A list of connection string objects. | <pre>list(object({<br>    name  = string<br>    type  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | Cross origin resource sharing configuration. | <pre>object({<br>    allowed_origins     = list(string)<br>    support_credentials = optional(bool, null)<br>  })</pre> | `null` | no |
| <a name="input_create_application_insights"></a> [create\_application\_insights](#input\_create\_application\_insights) | Create an instance of Log Analytics and Application Insights for the app service. | `bool` | `true` | no |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | The custom domain name for the app service | `string` | `null` | no |
| <a name="input_identity_options"></a> [identity\_options](#input\_identity\_options) | Options relating to the UMID of the App Service | <pre>object({<br>    // If use_umid is true but a custom name nor an ID is specified, a UMID will be created with default naming.<br>    use_umid         = optional(bool, true)<br>    umid_custom_name = optional(string)<br>    umid_id          = optional(string) // If a UMID already exists, you can specify it here<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_logs"></a> [logs](#input\_logs) | The log configuration to use with this app service. | <pre>object({<br>    level                   = optional(string, "Warning")<br>    detailed_error_messages = optional(bool, false)<br>    failed_request_tracing  = optional(bool, false)<br>    retention_in_days       = optional(number, 7)<br>    retention_in_mb         = optional(number, 100)<br>  })</pre> | `{}` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Object detailing the plan, if creating one with this module. | <pre>object({<br>    create         = optional(bool, true)<br>    id             = optional(string)<br>    name           = optional(string)<br>    sku_name       = optional(string, "B1")<br>    zone_balancing = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Do you want to enable public access | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_site_config"></a> [site\_config](#input\_site\_config) | An object with site config values. | <pre>object({<br>    always_on                                     = optional(bool, false)<br>    api_definition_url                            = optional(string)<br>    api_management_api_id                         = optional(string)<br>    app_command_line                              = optional(string)<br>    container_registry_managed_identity_client_id = optional(string)<br>    container_registry_use_managed_identity       = optional(bool, true)<br>    default_documents                             = optional(list(string))<br>    health_check_eviction_time_in_min             = optional(number, 2)<br>    ftps_state                                    = optional(string)<br>    health_check_path                             = optional(string)<br>    http2_enabled                                 = optional(bool, false)<br>    load_balancing_mode                           = optional(string)<br>    local_mysql_enabled                           = optional(bool)<br>    managed_pipeline_mode                         = optional(string)<br>    minimum_tls_version                           = optional(string, "1.2")<br>    scm_minimum_tls_version                       = optional(string, "1.2")<br>    scm_use_main_ip_restriction                   = optional(bool)<br>    remote_debugging_enabled                      = optional(bool, false)<br>    remote_debugging_version                      = optional(string)<br>    use_32_bit_worker                             = optional(bool)<br>    vnet_route_all_enabled                        = optional(bool)<br>    websockets_enabled                            = optional(bool, false)<br>    worker_count                                  = optional(number, 1)<br>  })</pre> | `{}` | no |
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
| [azurerm_app_service_certificate.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate) | resource |
| [azurerm_app_service_certificate_binding.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate_binding) | resource |
| [azurerm_app_service_custom_hostname_binding.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_custom_hostname_binding) | resource |
| [azurerm_app_service_managed_certificate.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_managed_certificate) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_certificate.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_linux_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_linux_web_app_slot.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app_slot) | resource |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_autoscale_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_user_assigned_identity.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_windows_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) | resource |
| [azurerm_windows_web_app_slot.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app_slot) | resource |
| [null_resource.validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |