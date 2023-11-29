# Terraform (Module) - AzureRM - Spoke

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module deploys a spoke network in Azure.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address spaces of the virtual network. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the spoke virtual network. | `string` | n/a | yes |
| <a name="input_default_route_ip"></a> [default\_route\_ip](#input\_default\_route\_ip) | The IP address to use for the default route if creating a route table. | `string` | `null` | no |
| <a name="input_default_route_name"></a> [default\_route\_name](#input\_default\_route\_name) | The name of the default route. | `string` | `"default"` | no |
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable. | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `[]` | no |
| <a name="input_hub_peering"></a> [hub\_peering](#input\_hub\_peering) | Config for peering to the hub network. | <pre>map(object({<br>    id                           = string<br>    allow_virtual_network_access = optional(bool, true)<br>    allow_forwarded_traffic      = optional(bool, true)<br>    allow_gateway_transit        = optional(bool, false)<br>    use_remote_gateways          = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name) | The name of the network security group. | `string` | `null` | no |
| <a name="input_nsg_rules_inbound"></a> [nsg\_rules\_inbound](#input\_nsg\_rules\_inbound) | A list of objects describing a rule inbound. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_nsg_rules_outbound"></a> [nsg\_rules\_outbound](#input\_nsg\_rules\_outbound) | A list of objects describing a rule outbound. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_route_table_name"></a> [route\_table\_name](#input\_route\_table\_name) | The name of the route table. | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to create in this virtual network with the map name indicating the subnet name. | <pre>map(object({<br>    prefix                                        = string<br>    service_endpoints                             = optional(list(string))<br>    private_endpoint_network_policies_enabled     = optional(bool)<br>    private_link_service_network_policies_enabled = optional(bool)<br>    delegations = optional(map(<br>      object({<br>        service = string<br>        actions = list(string)<br>      })<br>    ), {})<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The output of the network module. |
| <a name="output_network"></a> [network](#output\_network) | The output of the network module. |
| <a name="output_network_security_group"></a> [network\_security\_group](#output\_network\_security\_group) | The output of the network security group resource. |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | The output of the route table rsource. |

## Resources

| Name | Type |
|------|------|
| [azurerm_route.main_default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_virtual_network_peering.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ans-coe/virtual-network/azurerm | 1.3.0 |
| <a name="module_network_security_group"></a> [network\_security\_group](#module\_network\_security\_group) | ../network-security-group | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |