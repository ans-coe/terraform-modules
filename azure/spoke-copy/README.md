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
- A default NSG is created
- A default Route Table with default Route is created
- Option for peering to and from the hub vNet

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.85 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address spaces of the virtual network. | `list(string)` | n/a | yes |
| <a name="input_create_global_nat_gateway"></a> [create\_global\_nat\_gateway](#input\_create\_global\_nat\_gateway) | Create a NAT Gateway to associate with all subnets. | `any` | n/a | yes |
| <a name="input_default_route_ip"></a> [default\_route\_ip](#input\_default\_route\_ip) | Default route IP Address. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the spoke virtual network. | `string` | n/a | yes |
| <a name="input_nat_gateways"></a> [nat\_gateways](#input\_nat\_gateways) | A map of objects describing custom NAT Gateways with associated subnets. | <pre>map(object({<br>    location            = string<br>    resource_group_name = string<br>    subnets             = optional(list(string), null)<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP Community for this virtual network. | `string` | `null` | no |
| <a name="input_create_global_nsg"></a> [create\_global\_nsg](#input\_create\_global\_nsg) | Create a Network Security Group to associate with all subnets. | `bool` | `true` | no |
| <a name="input_create_global_route_table"></a> [create\_global\_route\_table](#input\_create\_global\_route\_table) | Create a route table to associate with all subnets. | `bool` | `true` | no |
| <a name="input_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#input\_ddos\_protection\_plan\_id) | A DDoS Protection plan ID to assign to the virtual network. | `string` | `null` | no |
| <a name="input_default_route_name"></a> [default\_route\_name](#input\_default\_route\_name) | Name of the default route. | `string` | `"default-route"` | no |
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable. | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `[]` | no |
| <a name="input_hub_peering"></a> [hub\_peering](#input\_hub\_peering) | Config for peering to the hub network. | <pre>map(object({<br>    id                           = string<br>    create_reverse_peering       = optional(bool, true)<br>    hub_resource_group_name      = string<br>    allow_virtual_network_access = optional(bool, true)<br>    allow_forwarded_traffic      = optional(bool, true)<br>    allow_gateway_transit        = optional(bool, false)<br>    use_remote_gateways          = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_include_azure_dns"></a> [include\_azure\_dns](#input\_include\_azure\_dns) | If using custom DNS servers, include Azure DNS IP as a DNS server. | `bool` | `false` | no |
| <a name="input_nat_gateway_name"></a> [nat\_gateway\_name](#input\_nat\_gateway\_name) | Name of the global NAT Gateway to be created. | `string` | `"default-ngw"` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | A map of objects describing custom Network Security Groups with associated subnets. | <pre>map(object({<br>    location            = string<br>    resource_group_name = optional(string)<br>    subnets             = optional(list(string), null)<br><br>    nsg_rules_inbound = optional(list(object({<br>      rule                                       = optional(string)<br>      name                                       = string<br>      description                                = optional(string, "Created by Terraform.")<br>      nsg_name                                   = optional(string, "default_nsg")<br>      access                                     = optional(string, "Allow")<br>      priority                                   = optional(number)<br>      protocol                                   = optional(string, "*")<br>      ports                                      = optional(set(string), ["*"])<br>      source_prefixes                            = optional(set(string), ["*"])<br>      destination_prefixes                       = optional(set(string), ["VirtualNetwork"])<br>      source_application_security_group_ids      = optional(set(string), null)<br>      destination_application_security_group_ids = optional(set(string), null)<br>    })), [])<br><br>    nsg_rules_outbound = optional(list(object({<br>      rule                                       = optional(string)<br>      name                                       = string<br>      description                                = optional(string, "Created by Terraform.")<br>      access                                     = optional(string, "Allow")<br>      priority                                   = optional(number)<br>      protocol                                   = optional(string, "*")<br>      ports                                      = optional(set(string), ["*"])<br>      source_prefixes                            = optional(set(string), ["*"])<br>      destination_prefixes                       = optional(set(string), ["VirtualNetwork"])<br>      source_application_security_group_ids      = optional(set(string), null)<br>      destination_application_security_group_ids = optional(set(string), null)<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_nsg_name"></a> [nsg\_name](#input\_nsg\_name) | Name of the global Network Security Group to be created. | `string` | `"default-nsg"` | no |
| <a name="input_nsg_rules_inbound"></a> [nsg\_rules\_inbound](#input\_nsg\_rules\_inbound) | A list of objects describing a rule inbound for the global Network Security Group. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br>    nsg_name    = optional(string, "default_nsg")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_nsg_rules_outbound"></a> [nsg\_rules\_outbound](#input\_nsg\_rules\_outbound) | A list of objects describing a rule outbound for the global Network Security Group. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br>    nsg_name    = optional(string, "default_nsg")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | Private DNS Zones to link to this virtual network with the map name indicating the private dns zone name. | <pre>map(object({<br>    resource_group_name  = string<br>    registration_enabled = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_route_table_name"></a> [route\_table\_name](#input\_route\_table\_name) | Name of the global route table to be created. | `string` | `"default-rt"` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | A map of objects describing custom route tables with associated subnets. | <pre>map(object({<br>    resource_group_name           = string<br>    disable_bgp_route_propagation = optional(bool, true)<br>    subnets                       = optional(list(string), null)<br>    routes = optional(map(object({<br>      address_prefix         = string<br>      next_hop_type          = optional(string, "VirtualAppliance")<br>      next_hop_in_ip_address = optional(string)<br>    })))<br>    default = {}<br>  }))</pre> | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to create in this virtual network with the map name indicating the subnet name. | <pre>map(object({<br>    prefixes                                      = list(string)<br>    resource_group_name                           = optional(string)<br>    service_endpoints                             = optional(list(string))<br>    private_endpoint_network_policies_enabled     = optional(bool)<br>    private_link_service_network_policies_enabled = optional(bool)<br>    delegations = optional(map(<br>      object({<br>        service = string<br>        actions = list(string)<br>      })<br>    ), {})<br>    associate_global_route_table = optional(bool, true)<br>    associate_global_nsg         = optional(bool, true)<br>    associate_global_nat_gateway = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The output of the network module. |
| <a name="output_network"></a> [network](#output\_network) | The output of the network module. |
| <a name="output_network_security_group"></a> [network\_security\_group](#output\_network\_security\_group) | The output of the network security group resource. |
| <a name="output_network_security_group_config"></a> [network\_security\_group\_config](#output\_network\_security\_group\_config) | n/a |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | The output of the route table rsource. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network_peering.reverse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_custom_route_tables"></a> [custom\_route\_tables](#module\_custom\_route\_tables) | ./_modules/route-table | n/a |
| <a name="module_global_route_table"></a> [global\_route\_table](#module\_global\_route\_table) | ./_modules/route-table | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./_modules/vnet | n/a |
| <a name="module_network_security_group"></a> [network\_security\_group](#module\_network\_security\_group) | ../network-security-group | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |