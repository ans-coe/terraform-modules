# Example - Backup

This example is used to illustrate the usage of this module with a backup.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_password"></a> [password](#input\_password) | VM Password. | `string` | n/a | yes |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_recovery_services_vault.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |
| [azurerm_resource_group.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_backup_policy_vm.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/backup_policy_vm) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vm"></a> [vm](#module\_vm) | ../../ | n/a |
<!-- END_TF_DOCS -->
