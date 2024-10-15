<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.74 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Application type, values can be App Attach, External Parties, Microsoft Edge. ETC | `string` | n/a | yes |
| <a name="input_charge_code"></a> [charge\_code](#input\_charge\_code) | Project charge code | `string` | n/a | yes |
| <a name="input_criticality"></a> [criticality](#input\_criticality) | Project criticality | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | Data Classification | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Project environment | `string` | n/a | yes |
| <a name="input_lbsPatchDefinitions"></a> [lbsPatchDefinitions](#input\_lbsPatchDefinitions) | LBS Patch Definitions | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region to use. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_shared_image_gallery_name"></a> [shared\_image\_gallery\_name](#input\_shared\_image\_gallery\_name) | Specifies the name of the Shared Image Gallery. | `string` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_community_gallery"></a> [community\_gallery](#input\_community\_gallery) | Configure the Shared Image Gallery as a Community Gallery. | <pre>object({<br>    eula            = string<br>    prefix          = string<br>    publisher_email = string<br>    publisher_uri   = string<br>  })</pre> | `null` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| <a name="input_shared_image_gallery_description"></a> [shared\_image\_gallery\_description](#input\_shared\_image\_gallery\_description) | A description for this Shared Image Gallery. | `string` | `null` | no |
| <a name="input_shared_images_definitions"></a> [shared\_images\_definitions](#input\_shared\_images\_definitions) | Create Shared Image Definition. | <pre>list(object({<br>    name = string<br>    identifier = object({<br>      offer     = string<br>      publisher = string<br>      sku       = string<br>    })<br>    os_type                             = string<br>    description                         = optional(string)<br>    disk_types_not_allowed              = optional(list(string))<br>    end_of_life_date                    = optional(string)<br>    eula                                = optional(string)<br>    specialized                         = optional(bool)<br>    architecture                        = optional(string, "x64")<br>    hyper_v_generation                  = optional(string, "V2")<br>    max_recommended_vcpu_count          = optional(number)<br>    min_recommended_vcpu_count          = optional(number)<br>    max_recommended_memory_in_gb        = optional(number)<br>    min_recommended_memory_in_gb        = optional(number)<br>    privacy_statement_uri               = optional(string)<br>    release_note_uri                    = optional(string)<br>    trusted_launch_enabled              = optional(bool)<br>    confidential_vm_supported           = optional(bool)<br>    confidential_vm_enabled             = optional(bool)<br>    accelerated_network_support_enabled = optional(bool)<br>    tags                                = optional(map(string))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Azure Shared Image Gallery ID |
| <a name="output_name"></a> [name](#output\_name) | Azure Shared Image Gallery name |
| <a name="output_shared_image_gallery"></a> [shared\_image\_gallery](#output\_shared\_image\_gallery) | Azure Shared Image Gallery output object |
| <a name="output_shared_images_definitions"></a> [shared\_images\_definitions](#output\_shared\_images\_definitions) | Azure Shared Images definitions |

## Resources

| Name | Type |
|------|------|
| [azurerm_shared_image.shared_image](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_shared_image_gallery.shared_image_gallery](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->