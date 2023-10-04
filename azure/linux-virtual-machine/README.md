# Terraform - Linux VM

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This configuration creates a Linux VM with some simple extensions for management and monitoring.

When using a marketplace image, ensure that you accept the terms using the cli tools:

[Azure CLI](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage#accept-the-terms)
[PowerShell](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage#accept-purchase-plan-terms)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the virtual machine. | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Public key of the virtual machine. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID of the virtual machine. | `string` | n/a | yes |
| <a name="input_accept_terms"></a> [accept\_terms](#input\_accept\_terms) | Enable if terms are needed to be accepted | `bool` | `false` | no |
| <a name="input_agw_backend_address_pool_ids"></a> [agw\_backend\_address\_pool\_ids](#input\_agw\_backend\_address\_pool\_ids) | IDs of application gateways backends to assign this virtual machine's primary NIC to. | `list(string)` | `[]` | no |
| <a name="input_autoshutdown"></a> [autoshutdown](#input\_autoshutdown) | Describes the autoshutdown configuration with time being in 24h format and timezone being a supported timezone. | <pre>object({<br>    time     = optional(string, "2200")<br>    timezone = optional(string, "UTC")<br>    email    = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id) | Availability set ID to add this virtual machine to. | `string` | `null` | no |
| <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name) | The OS-level computer name of the virtual machine. | `string` | `null` | no |
| <a name="input_data_collection_enabled"></a> [data\_collection\_enabled](#input\_data\_collection\_enabled) | Enable data collection association. | `bool` | `false` | no |
| <a name="input_data_collection_rule_id"></a> [data\_collection\_rule\_id](#input\_data\_collection\_rule\_id) | Data collection rule ID to associate to this virtual machine. | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `null` | no |
| <a name="input_enable_aad_login"></a> [enable\_aad\_login](#input\_enable\_aad\_login) | Enable AAD Login extension. | `bool` | `true` | no |
| <a name="input_enable_azure_monitor"></a> [enable\_azure\_monitor](#input\_enable\_azure\_monitor) | Enable Azure Monitor extension. | `bool` | `true` | no |
| <a name="input_enable_azure_policy"></a> [enable\_azure\_policy](#input\_enable\_azure\_policy) | Enable Azure Policy extension. | `bool` | `true` | no |
| <a name="input_enable_network_watcher"></a> [enable\_network\_watcher](#input\_enable\_network\_watcher) | Enable Network Watcher extension. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User assigned identity IDs to append to this virtual machine. | `list(string)` | `[]` | no |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | Private IP address of the virtual machine NIC. | `string` | `null` | no |
| <a name="input_ip_forwarding"></a> [ip\_forwarding](#input\_ip\_forwarding) | Enable IP forwarding on the virtual machine NIC. | `bool` | `false` | no |
| <a name="input_lb_backend_address_pool_ids"></a> [lb\_backend\_address\_pool\_ids](#input\_lb\_backend\_address\_pool\_ids) | IDs of load balancer backends to assign this virtual machine's primary NIC to. | `list(string)` | `[]` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License type to use when building the virtual machine. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_network_security_group_enabled"></a> [network\_security\_group\_enabled](#input\_network\_security\_group\_enabled) | Assign a network security group. | `bool` | `false` | no |
| <a name="input_network_security_group_id"></a> [network\_security\_group\_id](#input\_network\_security\_group\_id) | ID of the network security group to use with the virtual machine NIC. | `string` | `null` | no |
| <a name="input_os_disk_caching"></a> [os\_disk\_caching](#input\_os\_disk\_caching) | Caching option of the OS Disk. | `string` | `"None"` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | Size of the OS Disk in GB. | `number` | `128` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | Type of the storage account. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode) | The patch assessment mode of the virtual machine. | `string` | `null` | no |
| <a name="input_public_ip_enabled"></a> [public\_ip\_enabled](#input\_public\_ip\_enabled) | Enable public IP. | `bool` | `false` | no |
| <a name="input_size"></a> [size](#input\_size) | Size of the virtual machine. | `string` | `"Standard_B1s"` | no |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | Source image ID to use when creating the virtual machine. | `string` | `null` | no |
| <a name="input_source_image_plan_required"></a> [source\_image\_plan\_required](#input\_source\_image\_plan\_required) | Enable if plan block is required as part of the virtual machine. | `bool` | `false` | no |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | Source image reference to use when creating the virtual machine. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = optional(string, "latest")<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_user_data_b64"></a> [user\_data\_b64](#input\_user\_data\_b64) | User data of the virtual machine with in base64. | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | Username of the virtual machine. | `string` | `"vmadmin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_computer_name"></a> [computer\_name](#output\_computer\_name) | The OS-level computer name of the virtual machine. |
| <a name="output_id"></a> [id](#output\_id) | ID of the virtual machine. |
| <a name="output_identity"></a> [identity](#output\_identity) | ID of the virtual machine. |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | IP address of the virtual machine. |
| <a name="output_location"></a> [location](#output\_location) | Location of the virtual machine. |
| <a name="output_name"></a> [name](#output\_name) | Name of the virtual machine. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address of the virtual machine. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the virtual machine. |
| <a name="output_username"></a> [username](#output\_username) | The username on the created virtual machine. |

## Resources

| Name | Type |
|------|------|
| [azurerm_dev_test_global_vm_shutdown_schedule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule) | resource |
| [azurerm_linux_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_marketplace_agreement.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/marketplace_agreement) | resource |
| [azurerm_monitor_data_collection_rule_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_application_gateway_backend_address_pool_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_gateway_backend_address_pool_association) | resource |
| [azurerm_network_interface_backend_address_pool_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine_extension.main_aadlogin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_azdependencyagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_azmonitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_aznetworkwatcheragent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_azpolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |