# Example - Spoke -Basic

This example is used to illustrate the basic usage of this module.  It deploys a single spoke network.

For an advanced example use case of this module, please see: https://github.com/ans-coe/terraform-modules/blob/e36aab78f84662cc792382162c384ff56451cad8/azure/hub/examples/advanced

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.84 |

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_spoke"></a> [spoke](#module\_spoke) | ../../ | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |