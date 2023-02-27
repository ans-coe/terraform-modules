# Terraform Module - Azure - Terraform Ops

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module deploys resources that aid in managing Terraform operations including a Service Principal and permissions to Storage Accounts and Key Vaults created specifically for it.

Following deployment you must approve API permissions in the Azure Portal to allow AzureAD actions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.19 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 2.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Name of the key vault. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account. | `string` | n/a | yes |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | IPs or CIDRs allowed to connect to the created Key Vault and Storage Account. | `list(string)` | `null` | no |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | Subnet IDs allowed to connect to the created Key Vault and Storage Account. | `list(string)` | `null` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application created for Terraform. | `string` | `"Terraform"` | no |
| <a name="input_enable_purge_protection"></a> [enable\_purge\_protection](#input\_enable\_purge\_protection) | Enable purge protection on the key vault. | `bool` | `false` | no |
| <a name="input_enable_shared_access_key"></a> [enable\_shared\_access\_key](#input\_enable\_shared\_access\_key) | Enable shared access key on storage account. | `bool` | `true` | no |
| <a name="input_group_description"></a> [group\_description](#input\_group\_description) | Description used to create the Terraform Operators group. | `string` | `"A group for Terraform Users with access to core Terraform resources."` | no |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Name used to create the Terraform Operators group. | `string` | `"Terraform Operators"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_managed_scopes"></a> [managed\_scopes](#input\_managed\_scopes) | Scopes to be managed by Terraform. | `set(string)` | `[]` | no |
| <a name="input_managed_tenant_id"></a> [managed\_tenant\_id](#input\_managed\_tenant\_id) | The tenant id that will be used for management. | `string` | `null` | no |
| <a name="input_msgraph_roles"></a> [msgraph\_roles](#input\_msgraph\_roles) | Assignable MS Graph roles to allow MS Graph actions. | `list(string)` | <pre>[<br>  "Application.Read.All",<br>  "Group.Read.All",<br>  "User.Read.All"<br>]</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_terraform_group_member_ids"></a> [terraform\_group\_member\_ids](#input\_terraform\_group\_member\_ids) | Object IDs for administrative objects with full access to the Key Vault and Storage Account. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group"></a> [group](#output\_group) | Group details. |
| <a name="output_key_vault"></a> [key\_vault](#output\_key\_vault) | Key vault details. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |
| <a name="output_service_principal"></a> [service\_principal](#output\_service\_principal) | Service principal details. |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | Storage account details. |

## Resources

| Name | Type |
|------|------|
| [azuread_application.main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_group.main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.main_current_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_member.main_users](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_member.main_users_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_service_principal.main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.main_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.main_group_blob_owner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_kv_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_owner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.resource_group_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.main_state](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
