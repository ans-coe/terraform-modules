# Terraform Module - Azure - Container Registry

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module will deploy an Azure Container Registry with access to options related to premium features such as token support and georeplication.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the ACR. | `string` | n/a | yes |
| <a name="input_agent_pools"></a> [agent\_pools](#input\_agent\_pools) | Definitions for agent pools to create for this ACR. | <pre>list(object({<br>    name      = string<br>    instances = optional(number, 1)<br>    tier      = optional(string, "S1")<br>    subnet_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | CIDR ranges allowed access to this ACR. | `set(string)` | `[]` | no |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | Subnet IDs allowed access to this ACR. | `set(string)` | `[]` | no |
| <a name="input_enable_anonymous_pull"></a> [enable\_anonymous\_pull](#input\_enable\_anonymous\_pull) | Enable anonymous pull. | `bool` | `false` | no |
| <a name="input_enable_data_endpoint"></a> [enable\_data\_endpoint](#input\_enable\_data\_endpoint) | Enable data endpoint. | `bool` | `false` | no |
| <a name="input_enable_export_policy"></a> [enable\_export\_policy](#input\_enable\_export\_policy) | Enable export policy. Requires 'Premium' SKU. Requires public access to be disabled if false. | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Enable public access to ACR. | `bool` | `true` | no |
| <a name="input_enable_quarantine_policy"></a> [enable\_quarantine\_policy](#input\_enable\_quarantine\_policy) | Enable quarantine policy. Requires 'Premium' SKU. | `bool` | `false` | no |
| <a name="input_enable_retention_policy"></a> [enable\_retention\_policy](#input\_enable\_retention\_policy) | Enable retention policy. Requires 'Premium' SKU. | `bool` | `false` | no |
| <a name="input_enable_trust_policy"></a> [enable\_trust\_policy](#input\_enable\_trust\_policy) | Enable trust policy. Requires 'Premium' SKU. | `bool` | `false` | no |
| <a name="input_enable_zone_redundancy"></a> [enable\_zone\_redundancy](#input\_enable\_zone\_redundancy) | Enable zone redundancy. Requires 'Premium' SKU. | `bool` | `false` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Encryption configuration. | <pre>object({<br>    vault_key_id       = string<br>    identity_client_id = string<br>  })</pre> | `null` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | List of objects representing georeplications. | <pre>list(object({<br>    location                 = string<br>    enable_regional_endpoint = optional(bool, false)<br>    enable_zone_redundancy   = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Managed identity IDs to assign to this ACR. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_pull_object_ids"></a> [pull\_object\_ids](#input\_pull\_object\_ids) | Object IDs to grant the pull permission to. | `list(string)` | `[]` | no |
| <a name="input_push_object_ids"></a> [push\_object\_ids](#input\_push\_object\_ids) | Object IDs to grant the push permission to. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_retention_policy_days"></a> [retention\_policy\_days](#input\_retention\_policy\_days) | Days to retain untagged manifests. | `number` | `7` | no |
| <a name="input_scope_maps"></a> [scope\_maps](#input\_scope\_maps) | Scope maps to create for this ACR. | <pre>list(object({<br>    name        = string<br>    description = optional(string)<br>    actions     = set(string)<br>  }))</pre> | `[]` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU of the ACR. | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_webhooks"></a> [webhooks](#input\_webhooks) | Definitions for webhooks to create for this ACR. | <pre>list(object({<br>    name    = string<br>    uri     = string<br>    actions = list(string)<br>    enabled = optional(bool, true)<br>    scope   = optional(string)<br>    headers = optional(map(string), {})<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | Admin password for the container registry. |
| <a name="output_admin_user"></a> [admin\_user](#output\_admin\_user) | Admin user for the container registry. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the container registry. |
| <a name="output_location"></a> [location](#output\_location) | Location of the container registry. |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | Login server of the container registry. |
| <a name="output_name"></a> [name](#output\_name) | Name of the container registry. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |
| <a name="output_scope_maps"></a> [scope\_maps](#output\_scope\_maps) | Scope maps created with this module. |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_container_registry_agent_pool.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_agent_pool) | resource |
| [azurerm_container_registry_scope_map.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_scope_map) | resource |
| [azurerm_container_registry_webhook.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_webhook) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.main_acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_acr_push](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
