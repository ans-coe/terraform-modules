# Example - Hub - Advanced

This example deploys a hub network with two spoke networks.  A Firewall, Bastion, a Virtual Network Gateway and Private DNS Resolver are also configured as part of the deployment

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
| [azurerm_resource_group.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.prd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network_peering.hub-mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.hub-prd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.mgmt-hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.prd-hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firewall-policy"></a> [firewall-policy](#module\_firewall-policy) | ../../../firewall-policy | n/a |
| <a name="module_hub"></a> [hub](#module\_hub) | ../../ | n/a |
| <a name="module_spoke-mgmt"></a> [spoke-mgmt](#module\_spoke-mgmt) | ../../../spoke | n/a |
| <a name="module_spoke-prd"></a> [spoke-prd](#module\_spoke-prd) | ../../../spoke | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |