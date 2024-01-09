# Terraform (Module) - AzureRM - Virtual Network

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module will create an Azure Virtual Network with subnets using a complex object for configuration.

## Notes about use of bools within subnet

We use bools within var.subnets titled `associate_nsg`, `associate_rt` and `associate_ngw`.

Ideally we would have it so that if the values of `network_security_group_id`, `route_table_id` and `nat_gateway_id` were null, then the association is assumed to be true.

The bools are necessary because the for_each on the resource blocks for the association won't work if the keys in the maps are dependent on values that may or may not be null depending on the result of the apply step. Since the values of the `network_security_group_id`, `route_table_id` and `nat_gateway_id` are usually tied to attributes of resources outside of the module, then the keys of the local maps would be too

The issue is that the keys may or may not exist depending on if the apply step returns a null value for attribute they are linked to. Currently Terraform has no way for the AzureRM provider to indicate that the values of this cannot possibly be null.

Therefore, we need to link our keys to additional bools instead which are defined by the user in the config and not via the results of the apply stage.

A potential workaround for this would be to link the condition to something known before the apply step, such as a `name` attribute but then we would probably also need to add in the resource group and location attributes too and this would be even messier.

Terraform v1.6+ should allow the AzureRM provider to indicate that the values of the `network_security_group_id`, `route_table_id` and `nat_gateway_id` cannot possibly be null regardless of the results of the apply step. This will allow Terraform to set the keys based on the config written rather than on the results of the apply step.

However, we will need to wait for the AzureRM provider to include this indication before we can remove these bools. 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.85 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the virtual network. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address spaces of the virtual network. | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP Community for this virtual network. | `string` | `null` | no |
| <a name="input_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#input\_ddos\_protection\_plan\_id) | A DDoS Protection plan ID to assign to the virtual network. | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `[]` | no |
| <a name="input_include_azure_dns"></a> [include\_azure\_dns](#input\_include\_azure\_dns) | If using custom DNS servers, include Azure DNS IP as a DNS server. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | Private DNS Zones to link to this virtual network with the map name indicating the private dns zone name. | <pre>map(object({<br>    resource_group_name  = string<br>    registration_enabled = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | Address space of the virtual network. |
| <a name="output_id"></a> [id](#output\_id) | ID of the virtual network. |
| <a name="output_location"></a> [location](#output\_location) | Location of the virtual network. |
| <a name="output_name"></a> [name](#output\_name) | Name of the virtual network. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone_virtual_network_link.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_dns_servers.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |