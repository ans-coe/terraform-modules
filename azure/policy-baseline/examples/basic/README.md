# Example - Basic

This example is used to illustrate the basic usage of this module.

> NOTE: The values for scopes in this example are here for example purposes only. Terraform needs these values to be known prior to apply. Run the below to get it started, then a plain `terraform apply`.

```bash
terraform apply \
  -target data.azurerm_management_group.example -target data.azurerm_subscription.current \
  -target azurerm_resource_group.example_1 -target azurerm_resource_group.example_2 \
  -target azurerm_virtual_network.example_2
```

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
| [azurerm_resource_group.baseline_policies_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.baseline_policies_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.baseline_policies_3](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.baseline_policies_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.baseline_policies_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.baseline_policies_3](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_management_group.root](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_baseline_policies"></a> [baseline\_policies](#module\_baseline\_policies) | ../../ | n/a |
<!-- END_TF_DOCS -->
