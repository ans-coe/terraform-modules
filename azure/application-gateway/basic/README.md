# Terraform (Module) - Azure - Application Gateway

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module deploys and manages an Application Gateway instance and builds the necessary components for its backends. It also uses a default selfsign certificate to enable HTTPS straight away however this should only be utilised for the sake of building out the secure components.

As this module can be complex notes have been listed below to aid with its usage and explain some unclear parts.

  - The frontend ports "Http" and "Https" are provided by default, and used as defaults on frontends.
  - A selfsigned certificate is created as part of the AGW - this is there simply to enable creation of HTTPS endpoints and should be overridden with the `ssl_certificate_name` value and a provided `certificates` keyvault cert.
  - The backend address pool "default" is used if no other address pool name is provided.
  - Default WAF policy must be disabled explicitly with `default_waf_policy = { enabled = false }` if setting `firewall_policy_id` as `count` is used which prevents `firewall_policy_id` being used in the condition


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the application gateway. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID used to host the application gateway. | `string` | n/a | yes |
| <a name="input_autoscale_configuration"></a> [autoscale\_configuration](#input\_autoscale\_configuration) | Autoscaling configuration of this application gateway. | <pre>object({<br>    min_capacity = number<br>    max_capacity = number<br>  })</pre> | `null` | no |
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | Maps of objects contianing backend address pool information. | <pre>map(object({<br>    fqdns        = optional(list(string))<br>    ip_addresses = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_basic_backends"></a> [basic\_backends](#input\_basic\_backends) | Maps of objects containing backends with a basic configuration e.g. direct all traffic to backend. | <pre>map(object({<br>    hostname                 = string<br>    ssl_certificate_name     = optional(string, "selfsigned")<br>    http_frontend_port_name  = optional(string, "Http")<br>    https_frontend_port_name = optional(string, "Https")<br>    upgrade_connection       = optional(bool, true)<br>    private_frontend         = optional(bool, false)<br><br>    address_pool_name     = optional(string, "default")<br>    backend_hostname      = optional(string)<br>    backend_protocol      = optional(string, "Http")<br>    backend_port          = optional(number, 80)<br>    cookie_based_affinity = optional(bool, false)<br><br>    trusted_root_certificate_data = optional(string)<br>    probe = optional(object({<br>      enabled         = optional(bool, true)<br>      minimum_servers = optional(number)<br>      path            = optional(string, "/")<br>      body            = optional(string)<br>      status_codes    = optional(list(string), ["200-399"])<br>    }), {})<br>  }))</pre> | `{}` | no |
| <a name="input_certificates"></a> [certificates](#input\_certificates) | Map of name to key vault secret IDs for certificates to add to the application gateway. | `map(string)` | `{}` | no |
| <a name="input_custom_frontend_ports"></a> [custom\_frontend\_ports](#input\_custom\_frontend\_ports) | A map of names to port numbers to use on the frontend ports if the default Http=80 Https=443 are not sufficient. | `map(number)` | `{}` | no |
| <a name="input_default_waf_policy"></a> [default\_waf\_policy](#input\_default\_waf\_policy) | Configuration for the default WAF policy. | <pre>object({<br>    enabled           = optional(bool, true)<br>    name              = optional(string)<br>    enable_prevention = optional(bool, false)<br>    enable_bot_rules  = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Enables HTTP2 on the application gateway. | `bool` | `null` | no |
| <a name="input_enable_private_frontend"></a> [enable\_private\_frontend](#input\_enable\_private\_frontend) | Enable the private frontend on the application gateway. | `bool` | `false` | no |
| <a name="input_enable_public_frontend"></a> [enable\_public\_frontend](#input\_enable\_public\_frontend) | Enable the public frontend on the application gateway. | `bool` | `true` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | A firewall policy ID to use with this application gateway. | `string` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Managed identities to use on the application gateway. | `set(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_private_frontend_ip"></a> [private\_frontend\_ip](#input\_private\_frontend\_ip) | The private IP used on the private frontend. | `string` | `null` | no |
| <a name="input_private_frontend_subnet_id"></a> [private\_frontend\_subnet\_id](#input\_private\_frontend\_subnet\_id) | The subnet ID used for the private frontend. | `string` | `null` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | The name of the public IP address if overriding the default. | `string` | `null` | no |
| <a name="input_redirect_backends"></a> [redirect\_backends](#input\_redirect\_backends) | Maps of objects containing backends with a redirect configuration e.g. 301 to example.com. | <pre>map(object({<br>    hostname                 = string<br>    ssl_certificate_name     = optional(string, "selfsigned")<br>    http_frontend_port_name  = optional(string, "Http")<br>    https_frontend_port_name = optional(string, "Https")<br>    upgrade_connection       = optional(bool, false)<br>    private_frontend         = optional(bool, false)<br><br>    url = string<br>  }))</pre> | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU details of the application gateway. | <pre>object({<br>    name     = string<br>    tier     = string<br>    capacity = optional(number, 1)<br>  })</pre> | <pre>{<br>  "name": "Standard_v2",<br>  "tier": "Standard_v2"<br>}</pre> | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The predefined SSL policy to use with the application gateway. | `string` | `"AppGwSslPolicy20220101"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address_pools"></a> [backend\_address\_pools](#output\_backend\_address\_pools) | Backend address pools on the application gateway. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the application gateway. |
| <a name="output_ip"></a> [ip](#output\_ip) | IP address of the application gateway. |
| <a name="output_location"></a> [location](#output\_location) | Location of the application gateway. |
| <a name="output_name"></a> [name](#output\_name) | Name of the application gateway. |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address of the application gateway. |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.main_agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_web_application_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
