# Terraform (Module) - Azure - Application Gateway

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module will deploy and manage an application gateway.

To set auto-scalling, set sku.max_capacity to a value greater than sku.capacity.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | Map of backend address pools | <pre>map(object({<br>    ip_addresses = optional(list(string))<br>    fqdns        = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location where the Application Gateway will run | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Application Gateway | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet that the Application Gateway will belong to | `string` | n/a | yes |
| <a name="input_additional_frontend_ports"></a> [additional\_frontend\_ports](#input\_additional\_frontend\_ports) | Map of Additional Frontend Ports | `map(number)` | `{}` | no |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | Map of Backend HTTP Settings | <pre>map(object({<br>    port                                = optional(number, 80)<br>    protocol                            = optional(string, "Http")<br>    cookie_based_affinity               = optional(bool, true)<br>    affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")<br>    probe_name                          = optional(string, "DefaultProbe")<br>    host_name                           = optional(string)<br>    pick_host_name_from_backend_address = optional(bool, true)<br>    request_timeout                     = optional(number, 30)<br>    trusted_root_certificate_names      = optional(list(string))<br>  }))</pre> | <pre>{<br>  "DefaultSettings": {}<br>}</pre> | no |
| <a name="input_create_public_ip"></a> [create\_public\_ip](#input\_create\_public\_ip) | Set this bool to create a public IP address automatically | `bool` | `true` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Enables HTTP2 on the application gateway. | `bool` | `null` | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | Map of HTTP Listeners | <pre>map(object({<br>    frontend_ip_configuration_name = optional(string, "PublicFrontend")<br>    frontend_port_name             = optional(string, "Http")<br>    https_enabled                  = optional(bool, false)<br>    host_names                     = optional(list(string), [])<br>    ssl_certificate_name           = optional(string)<br>    routing = optional(map(object({<br>      //Path Based<br>      path_rules = optional(map(object({<br>        paths                      = list(string)<br>        backend_address_pool_name  = string<br>        backend_http_settings_name = optional(string, "DefaultSettings")<br>      })))<br>      redirect_configuration = optional(object({<br>        redirect_type        = optional(string, "Permanent")<br>        target_listener_name = optional(string)<br>        target_url           = optional(string)<br>        include_path         = optional(bool, true)<br>        include_query_string = optional(bool, true)<br>      }))<br>      backend_address_pool_name  = optional(string)<br>      backend_http_settings_name = optional(string, "DefaultSettings")<br>      priority                   = optional(number, 100)<br>      })),<br>      {<br>        DefaultRoutingRule = {<br>          backend_address_pool_name = "DefaultBackend"<br>        }<br>    })<br>  }))</pre> | <pre>{<br>  "DefaultListener": {}<br>}</pre> | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Map of potential UserAssigned identities | `list(string)` | `null` | no |
| <a name="input_pip_name"></a> [pip\_name](#input\_pip\_name) | Override The Public IP Name | `string` | `null` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | A private IP address for the frontend | `string` | `null` | no |
| <a name="input_probe"></a> [probe](#input\_probe) | Map of Probes | <pre>map(object({<br>    protocol                                  = optional(string, "Http")<br>    interval                                  = optional(number, 30)<br>    path                                      = optional(string, "/")<br>    timeout                                   = optional(number, 30)<br>    unhealthy_threshold                       = optional(number, 3)<br>    port                                      = optional(number, 80)<br>    pick_host_name_from_backend_http_settings = optional(bool, false)<br>    host                                      = optional(string)<br>    match = optional(list(object({<br>      body        = optional(string)<br>      status_code = optional(list(string))<br>      })), [{<br>      status_code = [<br>        "200-399"<br>      ]<br>    }])<br>  }))</pre> | <pre>{<br>  "DefaultProbe": {}<br>}</pre> | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Properties relating to the SKU of the Applicaton Gateway | <pre>object({<br>    name         = string<br>    tier         = string<br>    capacity     = optional(number, 1)<br>    max_capacity = optional(number, 1)<br>  })</pre> | <pre>{<br>  "name": "Standard_v2",<br>  "tier": "Standard_v2"<br>}</pre> | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | Map of SSL Certs | <pre>map(object({<br>    data                = optional(string)<br>    password            = optional(string)<br>    key_vault_secret_id = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The predefined SSL policy to use with the application gateway. | `string` | `"AppGwSslPolicy20220101"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource Tags | `map(string)` | `null` | no |
| <a name="input_trusted_root_certificate"></a> [trusted\_root\_certificate](#input\_trusted\_root\_certificate) | Map of SSL Certs | `map(string)` | `{}` | no |
| <a name="input_waf_configuration"></a> [waf\_configuration](#input\_waf\_configuration) | Rules Defining The WAF | <pre>object({<br>    policy_name              = string<br>    firewall_mode            = optional(string, "Prevention")<br>    rule_set_type            = optional(string, "OWASP")<br>    rule_set_version         = optional(string, "3.2")<br>    file_upload_limit_mb     = optional(number, 500)<br>    max_request_body_size_kb = optional(number, 128)<br>    managed_rule_exclusion = optional(list(object({<br>      match_variable          = string<br>      selector_match_operator = optional(string)<br>      selector                = optional(string)<br>    })), [])<br>    custom_rules = optional(map(object({<br>      priority = number<br>      action   = optional(string, "Block")<br>      match_conditions = list(object({<br>        match_values       = list(string)<br>        operator           = optional(string, "Contains")<br>        negation_condition = optional(bool, true)<br>        transforms         = optional(list(string))<br><br>        match_variables = optional(list(object({<br>          variable_name = string<br>          selector      = optional(string)<br>        })), [{ variable_name = "RemoteAddr" }])<br>      }))<br>    })), {})<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address_pool"></a> [backend\_address\_pool](#output\_backend\_address\_pool) | List of objects of Backend Address Pools |
| <a name="output_frontend_ip_configuration"></a> [frontend\_ip\_configuration](#output\_frontend\_ip\_configuration) | List of objects of Frontend IP Configurations |
| <a name="output_id"></a> [id](#output\_id) | ID of the application gateway. |
| <a name="output_location"></a> [location](#output\_location) | Location of the application gateway. |
| <a name="output_name"></a> [name](#output\_name) | Name of the application gateway. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_web_application_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
