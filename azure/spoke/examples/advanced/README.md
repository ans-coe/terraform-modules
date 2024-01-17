# Example - Spoke - Advanced

This example is used to illustrate the advanced usage of this module.

It deploys a single spoke network with the following resources:
 - 3 Resource Groups
 - 3 subnets
   - snet-prod
   - snet-app1 - not associated with an NSG
   - snet-app2 - not associated with a route table
 - Default Route Table (prod)
   - Default Route
   - 1 Extra Route
 - App2 Route Table
   - Default Rule
 - Default Network Security Group (prod)
   - 1 Inbound NSG Rule
   - 1 Outbound NSG Rule
 - App1 Network Security Group
   - 3 Inbound Rules
   - 2 Outbound Rules
 - Network Watcher
   - Flow Logs Enabled
 - Storage Account for Flow Logs
 - Log Analytics Workspace for Flow Logs



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.86 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Inputs

No inputs.

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.app1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.app2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.nw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_integer.sa](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app1-nsg"></a> [app1-nsg](#module\_app1-nsg) | ../../../network-security-group | n/a |
| <a name="module_app2-route-table"></a> [app2-route-table](#module\_app2-route-table) | ../../../route-table | n/a |
| <a name="module_spoke"></a> [spoke](#module\_spoke) | ../../ | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |