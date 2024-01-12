# Terraform (Module) - AzureRM - Spoke

#### Table of Contents

- [Terraform (Module) - AzureRM - Spoke](#terraform-module---azurerm---spoke)
      - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Resources](#resources)
  - [Modules](#modules)

## Usage

This module deploys a spoke network in Azure.
- There is an option to create a single NSG that can be applied to subnets if the associate_default_network_security_group is true (default).
- There is an option to create a single Route Table that can be applied to subnets if the associate_default_route_table is true (default).
- A default route is created can be created which routes "0.0.0.0/0" > default_route_ip.
- There is an option for peering to a hub vNet.  Peering from the hub vNet back to the Spoke is created when hub_peering.create_reverse_peering = true (default).
- Best practise is to create a Network Watcher per region & per subscription.  A Network Watcher is created if network_watcher_config.name is specified.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address spaces of the virtual network. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the spoke virtual network. | `string` | n/a | yes |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP Community for this virtual network. | `string` | `null` | no |
| <a name="input_create_default_network_security_group"></a> [create\_default\_network\_security\_group](#input\_create\_default\_network\_security\_group) | Create a Network Security Group to associate with all subnets. | `bool` | `true` | no |
| <a name="input_create_default_route_table"></a> [create\_default\_route\_table](#input\_create\_default\_route\_table) | Create a route table to associate with all subnets. | `bool` | `true` | no |
| <a name="input_create_network_watcher"></a> [create\_network\_watcher](#input\_create\_network\_watcher) | Enables Network Watcher for the region & subscription. | `bool` | `true` | no |
| <a name="input_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#input\_ddos\_protection\_plan\_id) | A DDoS Protection plan ID to assign to the virtual network. | `string` | `null` | no |
| <a name="input_default_route_ip"></a> [default\_route\_ip](#input\_default\_route\_ip) | Default route IP Address. | `string` | `null` | no |
| <a name="input_default_route_name"></a> [default\_route\_name](#input\_default\_route\_name) | Name of the default route. | `string` | `"default-route"` | no |
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | Disable Route Propagation. True = Disabled | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `[]` | no |
| <a name="input_extra_routes"></a> [extra\_routes](#input\_extra\_routes) | Routes to add to a custom route table. | <pre>map(object({<br>    address_prefix         = string<br>    next_hop_type          = optional(string, "VirtualAppliance")<br>    next_hop_in_ip_address = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_include_azure_dns"></a> [include\_azure\_dns](#input\_include\_azure\_dns) | If using custom DNS servers, include Azure DNS IP as a DNS server. | `bool` | `false` | no |
| <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name) | Name of the default Network Security Group | `string` | `"default-nsg"` | no |
| <a name="input_network_watcher_name"></a> [network\_watcher\_name](#input\_network\_watcher\_name) | Name of the Network Watcher | `string` | `null` | no |
| <a name="input_network_watcher_resource_group"></a> [network\_watcher\_resource\_group](#input\_network\_watcher\_resource\_group) | Name of the Network Watcher Resourece Group | `string` | `null` | no |
| <a name="input_nsg_rules_inbound"></a> [nsg\_rules\_inbound](#input\_nsg\_rules\_inbound) | A list of objects describing a rule inbound. | <pre>list(object({<br>    rule = optional(string)<br>    name = string<br>    # nsg_name    = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_nsg_rules_outbound"></a> [nsg\_rules\_outbound](#input\_nsg\_rules\_outbound) | A list of objects describing a rule outbound. | <pre>list(object({<br>    rule = optional(string)<br>    name = string<br>    # nsg_name    = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | Private DNS Zones to link to this virtual network with the map name indicating the private dns zone name. | <pre>map(object({<br>    resource_group_name  = string<br>    registration_enabled = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_route_table_name"></a> [route\_table\_name](#input\_route\_table\_name) | Name of the default Route Table | `string` | `"default-rt"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to create in this virtual network with the map name indicating the subnet name. | <pre>map(object({<br>    address_prefixes                              = list(string)<br>    service_endpoints                             = optional(list(string))<br>    private_endpoint_network_policies_enabled     = optional(bool)<br>    private_link_service_network_policies_enabled = optional(bool)<br>    delegations = optional(map(<br>      object({<br>        service = string<br>        actions = list(string)<br>      })<br>    ), {})<br>    associate_default_route_table            = optional(bool, true)<br>    associate_default_network_security_group = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_vnet_peering"></a> [vnet\_peering](#input\_vnet\_peering) | Config for peering to the other hub/spoke vnets. | <pre>map(object({<br>    id                           = string<br>    create_reverse_peering       = optional(bool, true)<br>    vnet_resource_group_name     = optional(string)<br>    allow_virtual_network_access = optional(bool, true)<br>    allow_forwarded_traffic      = optional(bool, true)<br>    allow_gateway_transit        = optional(bool, false)<br>    use_remote_gateways          = optional(bool, true)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The output of the network module. |
| <a name="output_network"></a> [network](#output\_network) | The output of the network module. |
| <a name="output_network_security_group"></a> [network\_security\_group](#output\_network\_security\_group) | The output of the network security group resource. |
| <a name="output_network_watcher"></a> [network\_watcher](#output\_network\_watcher) | The output of the Network Watcher. |
| <a name="output_nsg_rules_inbound"></a> [nsg\_rules\_inbound](#output\_nsg\_rules\_inbound) | The output of the Inbound NSG rules. |
| <a name="output_nsg_rules_outbound"></a> [nsg\_rules\_outbound](#output\_nsg\_rules\_outbound) | The output of the Outbound NSG rules. |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | The output of the route table rsource. |
| <a name="output_routes"></a> [routes](#output\_routes) | The output of all routes, default and custom. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | The output of the subnets. |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_watcher.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_resource_group.network_watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network_peering.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.reverse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ans-coe/virtual-network/azurerm | 1.3.0 |
| <a name="module_network_security_group"></a> [network\_security\_group](#module\_network\_security\_group) | ../network-security-group | n/a |
| <a name="module_route-table"></a> [route-table](#module\_route-table) | ../route-table | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |