# Example - Private Link

This example is used to illustrate usage of this module with a private link. It will create the web app and use a private link to connect it to a subnet in an isolated VNet.

> NOTE: Private Links will disable public reachability of the web app. This means that you will need some form of proxy to reach the webapp through the internet.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Inputs

No inputs.

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_webapp"></a> [webapp](#module\_webapp) | ../../ | n/a |
<!-- END_TF_DOCS -->
