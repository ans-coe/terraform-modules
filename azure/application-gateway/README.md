# Terraform (Module) - Azure - Application Gateway

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## TODO

- Outputs
- Examples
- README

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_gateway_name"></a> [application\_gateway\_name](#input\_application\_gateway\_name) | Name of the Application Gateway | `string` | n/a | yes |
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | List of backend address pools | <pre>list(object({<br>    name         = string<br>    ip_addresses = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_frontend_ip_configurations"></a> [frontend\_ip\_configurations](#input\_frontend\_ip\_configurations) | List of Frontend IP Configurations | <pre>list(object({<br>    name                 = string<br>    private_ip_address   = optional(string)<br>    public_ip_address_id = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | List of HTTP Listeners | <pre>list(object({<br>    name                           = string<br>    frontend_ip_configuration_name = string<br>    frontend_port_name             = optional(string, "Http")<br>    protocol                       = optional(string, "Http")<br>    host_name                      = optional(string)<br>    host_names                     = optional(list(string))<br>    ssl_certificate_name           = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location where the Application Gateway will run | `string` | n/a | yes |
| <a name="input_request_routing_rules"></a> [request\_routing\_rules](#input\_request\_routing\_rules) | List of Routing Rules | <pre>list(object({<br>    name                       = string<br>    rule_type                  = optional(string, "PathBasedRouting")<br>    http_listener_name         = string<br>    backend_address_pool_name  = optional(string)<br>    backend_http_settings_name = optional(string)<br>    url_path_map_name          = optional(string)<br>    priority                   = optional(number, 100)<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet that the Application Gateway will belong to | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource Tags | `map(string)` | n/a | yes |
| <a name="input_autoscale"></a> [autoscale](#input\_autoscale) | Properties relating to the Autoscalling of the Applicaton Gateway | <pre>object({<br>    min = string<br>    max = string<br>  })</pre> | <pre>{<br>  "max": "3",<br>  "min": "1"<br>}</pre> | no |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | List of Backend HTTP Settings | <pre>list(object({<br>    name                                = string<br>    port                                = optional(number, 80)<br>    protocol                            = optional(string, "Http")<br>    cookie_based_affinity               = optional(string, "Enabled")<br>    probe_name                          = optional(string, "Default")<br>    host_name                           = optional(string)<br>    pick_host_name_from_backend_address = optional(bool, true)<br>    request_timeout                     = optional(number, 30)<br>  }))</pre> | <pre>[<br>  {<br>    "name": "Default"<br>  }<br>]</pre> | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Boolean to defined whether to create the resource group or not | `bool` | `false` | no |
| <a name="input_frontend_ports"></a> [frontend\_ports](#input\_frontend\_ports) | List of Frontend Ports | <pre>list(object({<br>    name = string<br>    port = number<br>  }))</pre> | <pre>[<br>  {<br>    "name": "Http",<br>    "port": 80<br>  },<br>  {<br>    "name": "Https",<br>    "port": 443<br>  }<br>]</pre> | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of potential UserAssigned identities | `list(string)` | `null` | no |
| <a name="input_probe"></a> [probe](#input\_probe) | List of Routing Rules | <pre>list(object({<br>    name                                      = optional(string, "Default")<br>    protocol                                  = optional(string, "Http")<br>    interval                                  = optional(number, 30)<br>    path                                      = optional(string, "/")<br>    timeout                                   = optional(number, 30)<br>    unhealthy_threshold                       = optional(number, 3)<br>    port                                      = optional(number, 80)<br>    pick_host_name_from_backend_http_settings = optional(bool, false)<br>    host                                      = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "name": "Default"<br>  }<br>]</pre> | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Properties relating to the SKU of the Applicaton Gateway | <pre>object({<br>    name     = string<br>    tier     = string<br>    capacity = optional(string)<br>  })</pre> | <pre>{<br>  "name": "Standard_v2",<br>  "tier": "Standard_v2"<br>}</pre> | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | List of SSL Certs | <pre>list(object({<br>    name                = string<br>    data                = optional(string)<br>    password            = optional(string)<br>    key_vault_secret_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_url_path_maps"></a> [url\_path\_maps](#input\_url\_path\_maps) | List of Path Maps | <pre>list(object({<br>    name                               = string<br>    default_backend_address_pool_name  = string<br>    default_backend_http_settings_name = optional(string, "Default")<br>    path_rule = list(object({<br>      name                       = string<br>      paths                      = list(string)<br>      backend_address_pool_name  = string<br>      backend_http_settings_name = optional(string, "Default")<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_waf_configuration"></a> [waf\_configuration](#input\_waf\_configuration) | Rules Defining The WAF | <pre>object({<br>    policy_name              = string<br>    firewall_mode            = optional(string, "Prevention")<br>    rule_set_type            = optional(string, "OWASP")<br>    rule_set_version         = optional(string, "3.2")<br>    file_upload_limit_mb     = optional(number, 500)<br>    max_request_body_size_kb = optional(number, 128)<br>    managed_rule_exclusion = optional(list(object({<br>      match_variable          = string<br>      selector_match_operator = optional(string)<br>      selector                = optional(string)<br>    })), [])<br>    custom_rules = optional(list(object({<br>      name     = string<br>      priority = number<br>      action   = optional(string, "Block")<br>      match_conditions = list(object({<br>        match_values       = list(string)<br>        operator           = optional(string, "Contains")<br>        negation_condition = optional(bool, true)<br>        transforms         = optional(list(string))<br>        match_variables = optional(list(object({<br>          variable_name = string<br>          selector      = optional(string)<br>        })), [{ variable_name = "RemoteAddr" }])<br>      }))<br>    })), [])<br>  })</pre> | `null` | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_web_application_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
