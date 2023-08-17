# Terraform (Module) - Azurerm - Hub

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module deploys a predefined hub network with the option to include focused features such as a firewall, bastion, etc.

### Network Watcher
In order to manage network watcher via Terraform, the automatic creation of Network Watcher in Azure needs to be disabled in the subscription. Otherwise Terraform will error out.

az account set -s "SUBSCRIPTION NAME"
az feature register --name DisableNetworkWatcherAutocreation --namespace Microsoft.Network
az provider register -n Microsoft.Network


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Address range for the virtual network. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location to deploy to. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group created for the hub. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network. | `string` | n/a | yes |
| <a name="input_bastion_config"></a> [bastion\_config](#input\_bastion\_config) | Configuration for the bastion if enabled. | <pre>object({<br>    name                        = string<br>    resource_group_name         = optional(string)<br>    subnet_prefix               = string<br>    public_ip_name              = optional(string)<br>    network_security_group_name = optional(string)<br>    whitelist_cidrs             = optional(list(string), ["Internet"])<br>  })</pre> | `null` | no |
| <a name="input_extra_subnets"></a> [extra\_subnets](#input\_extra\_subnets) | Miscelaneous additional subnets to add. | <pre>map(object({<br>    prefix                                        = string<br>    service_endpoints                             = optional(list(string))<br>    private_endpoint_network_policies_enabled     = optional(bool)<br>    private_link_service_network_policies_enabled = optional(bool)<br>    delegations = optional(map(<br>      object({<br>        service = string<br>        actions = list(string)<br>      })<br>    ), {})<br>  }))</pre> | `{}` | no |
| <a name="input_firewall_config"></a> [firewall\_config](#input\_firewall\_config) | Configuration for the firewall if enabled. | <pre>object({<br>    name             = string<br>    subnet_prefix    = string<br>    public_ip_name   = optional(string)<br>    sku_tier         = optional(string, "Standard")<br>    route_table_name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log analytics workspace ID to forward diagnostics to. | `string` | `null` | no |
| <a name="input_network_watcher_config"></a> [network\_watcher\_config](#input\_network\_watcher\_config) | Configuration for the network watcher resource. | <pre>object({<br>    name                = optional(string)<br>    resource_group_name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_private_dns_domains"></a> [private\_dns\_domains](#input\_private\_dns\_domains) | A set of private domains to configure. | `set(string)` | `[]` | no |
| <a name="input_private_endpoint_subnet"></a> [private\_endpoint\_subnet](#input\_private\_endpoint\_subnet) | Configuration for the Private Endpoint subnet. | <pre>object({<br>    subnet_name   = optional(string, "snet-pe")<br>    subnet_prefix = string<br>    service_endpoints = optional(list(string), [<br>      "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB",<br>      "Microsoft.ContainerRegistry", "Microsoft.EventHub",<br>      "Microsoft.KeyVault", "Microsoft.ServiceBus",<br>      "Microsoft.Sql", "Microsoft.Storage",<br>      "Microsoft.Web"<br>    ])<br>  })</pre> | `null` | no |
| <a name="input_private_resolver_config"></a> [private\_resolver\_config](#input\_private\_resolver\_config) | Configuration for virtual network gateway if enabled. | <pre>object({<br>    name                   = string<br>    inbound_endpoint_name  = optional(string)<br>    inbound_subnet_name    = optional(string, "snet-dnspr-in")<br>    inbound_subnet_prefix  = string<br>    outbound_endpoint_name = optional(string)<br>    outbound_subnet_name   = optional(string, "snet-dnspr-out")<br>    outbound_subnet_prefix = string<br>  })</pre> | `null` | no |
| <a name="input_spoke_networks"></a> [spoke\_networks](#input\_spoke\_networks) | Maps of network name to network ID. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to append to resources. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_gateway_config"></a> [virtual\_network\_gateway\_config](#input\_virtual\_network\_gateway\_config) | Configuration for virtual network gateway if enabled. | <pre>object({<br>    name           = string<br>    subnet_prefix  = string<br>    public_ip_name = optional(string)<br>    sku            = optional(string, "VpnGw1")<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion"></a> [bastion](#output\_bastion) | Output from the bastion module. |
| <a name="output_default_route_table"></a> [default\_route\_table](#output\_default\_route\_table) | Default route table passing traffic through the firewall. |
| <a name="output_firewall"></a> [firewall](#output\_firewall) | Output from the firewall. |
| <a name="output_id"></a> [id](#output\_id) | Output from the network module. |
| <a name="output_network"></a> [network](#output\_network) | Output from the network module. |
| <a name="output_network_watcher"></a> [network\_watcher](#output\_network\_watcher) | Output of the network watcher. |
| <a name="output_private_resolver"></a> [private\_resolver](#output\_private\_resolver) | Output from the private resolver. |
| <a name="output_private_resolver_inbound_endpoint"></a> [private\_resolver\_inbound\_endpoint](#output\_private\_resolver\_inbound\_endpoint) | Output from the private resolver inbound endpoint. |
| <a name="output_private_resolver_outbound_endpoint"></a> [private\_resolver\_outbound\_endpoint](#output\_private\_resolver\_outbound\_endpoint) | Output from the private resolver outbound endpoint. |
| <a name="output_virtual_network_gateway"></a> [virtual\_network\_gateway](#output\_virtual\_network\_gateway) | Output from the virtual network gateway. |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_watcher.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_private_dns_resolver.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_inbound_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) | resource |
| [azurerm_private_dns_resolver_outbound_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) | resource |
| [azurerm_private_dns_zone.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_public_ip.virtual_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.network_watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_virtual_network_gateway.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | git::https://github.com/ans-coe/terraform-modules.git//azure/bastion/ | e9b156203385f9d4b1fc2facad2b1e8052029da7 |
| <a name="module_firewall"></a> [firewall](#module\_firewall) | git::https://github.com/ans-coe/terraform-modules.git//azure/firewall/ | b78fe8b96a456c7ffd3980b80e0b30c8c076ee29 |
| <a name="module_network"></a> [network](#module\_network) | ans-coe/virtual-network/azurerm | 1.3.0 |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |