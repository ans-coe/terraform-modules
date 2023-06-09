# Example - Advanced

This example is used to illustrate advanced usage of this module. It will create a subnet and attach the created function app to it.

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
| [azurerm_resource_group.functionapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.functionapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_subnet.functionapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.functionapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_functionapp"></a> [functionapp](#module\_functionapp) | ../../ | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |