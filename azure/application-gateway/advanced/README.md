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

To set auto-scaling, set sku.max_capacity to a value greater than sku.capacity.

Default Port Names are: `"http"` for 80 and `"https"` for 443.

### WAF_v2

You can only enable WAF_v2 by setting any of the `waf_configuration`, `listener_waf_configuration` or `path_rule_waf_configuration` variables. If any of these variable are set, then the WAF is enabled, otherwise the WAF is disabled.

Use `waf_configuration` for 'global' WAF settings. This creates a policy which applies to the whole WAF. Use `listener_waf_configuration` or `path_rule_waf_configuration` for local settings. These maps create policies which apply specifically to listeners and path rules defined in `associated_listeners` and `associated_path_rules` respectively.

When using `listener_waf_configuration` or `path_rule_waf_configuration`, you can only specify a listener or path rule once across all policies. A listener or path rule is only allowed to be linked to a single policy.

If `waf_configuration` is removed, the application gateway will need replacing otherwise Terraform will try to delete the firewall policy before removing it from the AGW which will result in a 400 error from AzureRM. 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | > 3.36 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | Map of backend address pools | <pre>map(object({<br>    ip_addresses = optional(list(string))<br>    fqdns        = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location where the Application Gateway will run | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Application Gateway | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet that the Application Gateway will belong to | `string` | n/a | yes |
| <a name="input_additional_frontend_ports"></a> [additional\_frontend\_ports](#input\_additional\_frontend\_ports) | Map of Additional Frontend Ports | `map(number)` | `{}` | no |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | Map of Backend HTTP Settings | <pre>map(object({<br>    port                           = optional(number, 80)<br>    https_enabled                  = optional(bool, false)<br>    cookie_based_affinity          = optional(bool, true)<br>    affinity_cookie_name           = optional(string, "ApplicationGatewayAffinity")<br>    probe_name                     = optional(string, "default_probe")<br>    host_name                      = optional(string)<br>    request_timeout                = optional(number, 30)<br>    trusted_root_certificate_names = optional(list(string))<br>    // pick_host_name_from_backend_address only applies when host_name is null<br>    pick_host_name_from_backend_address = optional(bool, true)<br>  }))</pre> | <pre>{<br>  "default_settings": {}<br>}</pre> | no |
| <a name="input_create_public_ip"></a> [create\_public\_ip](#input\_create\_public\_ip) | Set this bool to create a public IP address automatically | `bool` | `true` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Enables HTTP2 on the application gateway. | `bool` | `null` | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | Map of HTTP Listeners | <pre>map(object({<br>    frontend_ip_configuration_name = optional(string, "public_frontend")<br>    frontend_port_name             = optional(string, "http")<br>    https_enabled                  = optional(bool, false)<br>    host_names                     = optional(list(string), [])<br>    ssl_certificate_name           = optional(string)<br>    routing = optional(map(object({<br>      //Path Based<br>      path_rules = optional(map(object({<br>        paths                      = list(string)<br>        backend_address_pool_name  = string<br>        backend_http_settings_name = optional(string, "default_settings")<br>        rewrite_rule_set_name      = optional(string)<br>      })))<br>      redirect_configuration = optional(object({<br>        redirect_type        = optional(string, "Permanent")<br>        target_listener_name = optional(string)<br>        target_url           = optional(string)<br>        include_path         = optional(bool, true)<br>        include_query_string = optional(bool, true)<br>      }))<br>      backend_address_pool_name  = optional(string)<br>      backend_http_settings_name = optional(string, "default_settings")<br>      rewrite_rule_set_name      = optional(string)<br>      priority                   = optional(number, 100)<br>      })),<br>      {<br>        default_routing_rule = {<br>          backend_address_pool_name = "default_backend"<br>        }<br>    })<br>  }))</pre> | <pre>{<br>  "default_listener": {}<br>}</pre> | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Specify the value of the key vault ID to store the SSL certificates. Value is ignored if use\_key\_vault is false | `string` | `null` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Overwrite the name of the keyvault. Value is ignored if use\_key\_vault is false | `string` | `null` | no |
| <a name="input_key_vault_user_assigned_identity_name"></a> [key\_vault\_user\_assigned\_identity\_name](#input\_key\_vault\_user\_assigned\_identity\_name) | Overwrite the name of the umid. Value is ignored if use\_key\_vault is false | `string` | `null` | no |
| <a name="input_listener_waf_configuration"></a> [listener\_waf\_configuration](#input\_listener\_waf\_configuration) | Defining the WAF policy per listener | <pre>map(object({ // Key = policy name<br>    associated_listeners = list(string)<br>    firewall_mode        = optional(string, "Prevention")<br><br>    enable_OWASP           = optional(bool, true)<br>    OWASP_rule_set_version = optional(string, "3.2")<br>    OWASP_rule_group_override = optional(map(map(object({<br>      enabled = optional(bool, true)<br>      action  = optional(string)<br>    }))), {})<br><br>    enable_Microsoft_BotManagerRuleSet           = optional(bool, false)<br>    Microsoft_BotManagerRuleSet_rule_set_version = optional(string, "1.0")<br>    Microsoft_BotManagerRuleSet_rule_group_override = optional(map(map(object({<br>      enabled = optional(bool, true)<br>      action  = optional(string)<br>    }))), {})<br><br>    file_upload_limit_mb     = optional(number, 500)<br>    max_request_body_size_kb = optional(number, 128)<br>    managed_rule_exclusion = optional(list(object({<br>      match_variable          = string<br>      selector_match_operator = optional(string)<br>      selector                = optional(string)<br>    })), [])<br>    custom_rules = optional(map(object({<br>      priority = number<br>      action   = optional(string, "Block")<br>      match_conditions = list(object({<br>        match_values       = list(string)<br>        operator           = optional(string, "Contains")<br>        negation_condition = optional(bool, true)<br>        transforms         = optional(list(string))<br><br>        match_variables = optional(list(object({<br>          variable_name = string<br>          selector      = optional(string)<br>        })), [{ variable_name = "RemoteAddr" }])<br>      }))<br>    })), {})<br>  }))</pre> | `null` | no |
| <a name="input_path_rule_waf_configuration"></a> [path\_rule\_waf\_configuration](#input\_path\_rule\_waf\_configuration) | Defining the WAF policy per path rule | <pre>map(object({ // Key = policy name<br>    associated_path_rules = list(string)<br>    firewall_mode         = optional(string, "Prevention")<br><br>    enable_OWASP           = optional(bool, true)<br>    OWASP_rule_set_version = optional(string, "3.2")<br>    OWASP_rule_group_override = optional(map(map(object({<br>      enabled = optional(bool, true)<br>      action  = optional(string)<br>    }))), {})<br><br>    enable_Microsoft_BotManagerRuleSet           = optional(bool, false)<br>    Microsoft_BotManagerRuleSet_rule_set_version = optional(string, "1.0")<br>    Microsoft_BotManagerRuleSet_rule_group_override = optional(map(map(object({<br>      enabled = optional(bool, true)<br>      action  = optional(string)<br>    }))), {})<br><br>    file_upload_limit_mb     = optional(number, 500)<br>    max_request_body_size_kb = optional(number, 128)<br>    managed_rule_exclusion = optional(list(object({<br>      match_variable          = string<br>      selector_match_operator = optional(string)<br>      selector                = optional(string)<br>    })), [])<br>    custom_rules = optional(map(object({<br>      priority = number<br>      action   = optional(string, "Block")<br>      match_conditions = list(object({<br>        match_values       = list(string)<br>        operator           = optional(string, "Contains")<br>        negation_condition = optional(bool, true)<br>        transforms         = optional(list(string))<br><br>        match_variables = optional(list(object({<br>          variable_name = string<br>          selector      = optional(string)<br>        })), [{ variable_name = "RemoteAddr" }])<br>      }))<br>    })), {})<br>  }))</pre> | `null` | no |
| <a name="input_pip_name"></a> [pip\_name](#input\_pip\_name) | Override The Public IP Name | `string` | `null` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | A private IP address for the frontend | `string` | `null` | no |
| <a name="input_probe"></a> [probe](#input\_probe) | Map of Probes | <pre>map(object({<br>    https_enabled       = optional(bool, false)<br>    interval            = optional(number, 30)<br>    path                = optional(string, "/")<br>    timeout             = optional(number, 30)<br>    unhealthy_threshold = optional(number, 3)<br>    port                = optional(number)<br>    host                = optional(string)<br>    match = optional(list(object({<br>      body        = optional(string)<br>      status_code = optional(list(string))<br>      })), [{<br>      status_code = [<br>        "200-399"<br>      ]<br>    }])<br>  }))</pre> | <pre>{<br>  "default_probe": {}<br>}</pre> | no |
| <a name="input_rewrite_rule_set"></a> [rewrite\_rule\_set](#input\_rewrite\_rule\_set) | Map of rewrite rule sets | <pre>map( // key = rewrite_rule_set name<br>    map(      // key rewrite_rule name<br>      object({<br>        rule_sequence = number<br>        condition = optional(list(object({<br>          variable    = string<br>          pattern     = string<br>          ignore_case = optional(bool)<br>          negate      = optional(bool)<br>        })), [])<br>        request_header_configuration  = optional(map(string), {}) // key = header_name, value = header_value<br>        response_header_configuration = optional(map(string), {}) // key = header_name, value = header_value<br>        url = optional(list(object({<br>          path         = optional(string)<br>          query_string = optional(string)<br>          reroute      = optional(bool)<br>        })), [])<br>      })<br>    )<br>  )</pre> | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Properties relating to the SKU of the Applicaton Gateway | <pre>object({<br>    capacity     = optional(number, 1)<br>    max_capacity = optional(number)<br>  })</pre> | `{}` | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | Map of SSL Certs | <pre>map(object({<br>    data                = optional(string)<br>    password            = optional(string)<br>    key_vault_secret_id = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The predefined SSL policy to use with the application gateway. | `string` | `"AppGwSslPolicy20220101"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource Tags | `map(string)` | `null` | no |
| <a name="input_trusted_root_certificate"></a> [trusted\_root\_certificate](#input\_trusted\_root\_certificate) | Map of SSL Certs | `map(string)` | `{}` | no |
| <a name="input_use_key_vault"></a> [use\_key\_vault](#input\_use\_key\_vault) | Bool to use a keyvault. If key\_vault\_id is not set, a key vault will be created | `bool` | `true` | no |
| <a name="input_waf_configuration"></a> [waf\_configuration](#input\_waf\_configuration) | Defining the WAF policy globally on the App Gateway | <pre>object({<br>    policy_name   = string<br>    firewall_mode = optional(string, "Prevention")<br><br>    enable_OWASP           = optional(bool, true)<br>    OWASP_rule_set_version = optional(string, "3.2")<br>    OWASP_rule_group_override = optional(map(map(object({<br>      enabled = optional(bool, true)<br>      action  = optional(string)<br>    }))), {})<br><br>    enable_Microsoft_BotManagerRuleSet           = optional(bool, false)<br>    Microsoft_BotManagerRuleSet_rule_set_version = optional(string, "1.0")<br>    Microsoft_BotManagerRuleSet_rule_group_override = optional(map(map(object({<br>      enabled = optional(bool, true)<br>      action  = optional(string)<br>    }))), {})<br><br>    file_upload_limit_mb     = optional(number, 500)<br>    max_request_body_size_kb = optional(number, 128)<br>    managed_rule_exclusion = optional(list(object({<br>      match_variable          = string<br>      selector_match_operator = optional(string)<br>      selector                = optional(string)<br>    })), [])<br>    custom_rules = optional(map(object({<br>      priority = number<br>      action   = optional(string, "Block")<br>      match_conditions = list(object({<br>        match_values       = list(string)<br>        operator           = optional(string, "Contains")<br>        negation_condition = optional(bool, true)<br>        transforms         = optional(list(string))<br><br>        match_variables = optional(list(object({<br>          variable_name = string<br>          selector      = optional(string)<br>        })), [{ variable_name = "RemoteAddr" }])<br>      }))<br>    })), {})<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address_pool"></a> [backend\_address\_pool](#output\_backend\_address\_pool) | List of objects of Backend Address Pools |
| <a name="output_frontend_ip_configuration"></a> [frontend\_ip\_configuration](#output\_frontend\_ip\_configuration) | List of objects of Frontend IP Configurations |
| <a name="output_id"></a> [id](#output\_id) | ID of the application gateway. |
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | Identity of the AppGW if KV is used. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | principal\_id of the AppGW if KV is used. |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The id of the keyvault if one is set |
| <a name="output_location"></a> [location](#output\_location) | Location of the application gateway. |
| <a name="output_name"></a> [name](#output\_name) | Name of the application gateway. |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP Address |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP Address |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.main_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.main_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_certificate.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_user_assigned_identity.main_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_web_application_firewall_policy.listener](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |
| [azurerm_web_application_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |
| [azurerm_web_application_firewall_policy.path_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |