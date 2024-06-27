# Terraform (Module) - AzureRM - Virtual Machine

#### Table of Contents

- [Terraform (Module) - AzureRM - Virtual Machine](#terraform-module---azurerm---virtual-machine)
      - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Resources](#resources)
  - [Modules](#modules)

## Usage

This configuration creates a Linux or Windows VM with some simple extensions for management and monitoring.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the virtual machine. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID of the virtual machine. | `string` | n/a | yes |
| <a name="input_autoshutdown"></a> [autoshutdown](#input\_autoshutdown) | Describes the autoshutdown configuration of this virtual machine with time being 24h format and timezone being a supported timezone. Set to an empty map to enable. | <pre>object({<br>    time     = optional(string, "2200")<br>    timezone = optional(string, "UTC")<br>    email    = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id) | Availability set ID to add this virtual machine to. | `string` | `null` | no |
| <a name="input_backend_address_pool_ids"></a> [backend\_address\_pool\_ids](#input\_backend\_address\_pool\_ids) | IDs of load balancer backends to assign this virtual machine's primary NIC to. | `list(string)` | `[]` | no |
| <a name="input_backup_config"></a> [backup\_config](#input\_backup\_config) | Configuration of the backup. | <pre>object({<br>    backup_policy_id  = string<br>    include_disk_luns = optional(set(number))<br>    exclude_disk_luns = optional(set(number))<br>  })</pre> | `null` | no |
| <a name="input_boot_diagnostics_storage_account_uri"></a> [boot\_diagnostics\_storage\_account\_uri](#input\_boot\_diagnostics\_storage\_account\_uri) | Storage account blob endpoint to use for boot diagnostics. | `string` | `null` | no |
| <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name) | The OS-level computer name of the virtual machine. | `string` | `null` | no |
| <a name="input_data_collection_rule_id"></a> [data\_collection\_rule\_id](#input\_data\_collection\_rule\_id) | Data collection rule ID to associate to this virtual machine. | `string` | `null` | no |
| <a name="input_diagnostics_storage_account_name"></a> [diagnostics\_storage\_account\_name](#input\_diagnostics\_storage\_account\_name) | Name of the Storage Account in which store boot diagnostics and for legacy monitoring agent. | `string` | `null` | no |
| <a name="input_disk_attachments"></a> [disk\_attachments](#input\_disk\_attachments) | Disks to attach to this VM. | <pre>map(object({<br>    id      = string<br>    lun     = number<br>    caching = optional(string, "None")<br>  }))</pre> | `{}` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `null` | no |
| <a name="input_enable_aad_login"></a> [enable\_aad\_login](#input\_enable\_aad\_login) | Enable AAD Login extension. | `bool` | `true` | no |
| <a name="input_enable_accelerated_networking"></a> [enable\_accelerated\_networking](#input\_enable\_accelerated\_networking) | Should Accelerated Networking be enabled? | `bool` | `false` | no |
| <a name="input_enable_azure_monitor"></a> [enable\_azure\_monitor](#input\_enable\_azure\_monitor) | Enable Azure Monitor extension. | `bool` | `false` | no |
| <a name="input_enable_azure_policy"></a> [enable\_azure\_policy](#input\_enable\_azure\_policy) | Enable Azure Policy extension. | `bool` | `false` | no |
| <a name="input_enable_data_collection"></a> [enable\_data\_collection](#input\_enable\_data\_collection) | Enable data collection association. | `bool` | `false` | no |
| <a name="input_enable_dependency_agent"></a> [enable\_dependency\_agent](#input\_enable\_dependency\_agent) | Enable Azure Monitor Dependency Agent extension. | `bool` | `false` | no |
| <a name="input_enable_encryption_at_host"></a> [enable\_encryption\_at\_host](#input\_enable\_encryption\_at\_host) | Adds the option of adding enabling encryption at host | `bool` | `null` | no |
| <a name="input_enable_ip_forwarding"></a> [enable\_ip\_forwarding](#input\_enable\_ip\_forwarding) | Enable IP forwarding on the virtual machine NIC. | `bool` | `false` | no |
| <a name="input_enable_keyvault_extension"></a> [enable\_keyvault\_extension](#input\_enable\_keyvault\_extension) | Enable the Microsoft.Insights.VMDiagnosticsSettings Extention | `bool` | `false` | no |
| <a name="input_enable_network_security_group"></a> [enable\_network\_security\_group](#input\_enable\_network\_security\_group) | Assign a network security group. | `bool` | `false` | no |
| <a name="input_enable_network_watcher"></a> [enable\_network\_watcher](#input\_enable\_network\_watcher) | Enable Network Watcher extension. | `bool` | `false` | no |
| <a name="input_enable_public_ip"></a> [enable\_public\_ip](#input\_enable\_public\_ip) | Enable public IP. | `bool` | `false` | no |
| <a name="input_hotpatching_enabled"></a> [hotpatching\_enabled](#input\_hotpatching\_enabled) | Should the VM be patched without requiring a reboot?  Hotpatching can only be enabled if the patch\_mode is set to AutomaticByPlatform, the provision\_vm\_agent is set to true, your source\_image\_reference references a hotpatching enabled image, and the VM's size is set to a Azure generation 2 VM. | `string` | `false` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User assigned identity IDs to append to this virtual machine. | `list(string)` | `[]` | no |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | Private IP address of the virtual machine NIC. | `string` | `null` | no |
| <a name="input_keyvault_extension_settings"></a> [keyvault\_extension\_settings](#input\_keyvault\_extension\_settings) | Key Vault Extension settings. (json) | `any` | `null` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License type of the virtual machine. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_network_interface_name"></a> [network\_interface\_name](#input\_network\_interface\_name) | Name of the network interface. | `string` | `null` | no |
| <a name="input_network_security_group_id"></a> [network\_security\_group\_id](#input\_network\_security\_group\_id) | ID of the network security group to use with the virtual machine NIC. | `string` | `null` | no |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | OS Disk configuration. | <pre>object({<br>    name                 = optional(string)<br>    size_gb              = optional(number, 128)<br>    storage_account_type = optional(string, "StandardSSD_LRS")<br>    caching              = optional(string, "None")<br>  })</pre> | `{}` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The OS type to use. | `string` | `"Linux"` | no |
| <a name="input_password"></a> [password](#input\_password) | Password of the virtual machine. | `string` | `null` | no |
| <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode) | Patch assessment mode of the virtual machine. | `string` | `null` | no |
| <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode) | Patch mode of the virtual machine. | `string` | `null` | no |
| <a name="input_public_ip_allocation_method"></a> [public\_ip\_allocation\_method](#input\_public\_ip\_allocation\_method) | Public IP allocation method. | `string` | `"Dynamic"` | no |
| <a name="input_public_ip_hostname"></a> [public\_ip\_hostname](#input\_public\_ip\_hostname) | Public IP hostname. | `string` | `null` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | Name of the public IP. | `string` | `null` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Public key of the virtual machine. | `string` | `null` | no |
| <a name="input_size"></a> [size](#input\_size) | Size of the virtual machine. | `string` | `"Standard_B2s"` | no |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | Source image ID to use when creating the virtual machine. | `string` | `null` | no |
| <a name="input_source_image_plan_required"></a> [source\_image\_plan\_required](#input\_source\_image\_plan\_required) | Enable if plan block is required as part of the virtual machine. | `bool` | `false` | no |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | Source image reference to use when creating the virtual machine. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = optional(string, "latest")<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data of the virtual machine. | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | Username of the virtual machine. | `string` | `"vmadmin"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Specifies the Availability Zone in which this Windows Virtual Machine should be located. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attached_luns"></a> [attached\_luns](#output\_attached\_luns) | A map of the lun for each data disk attachment |
| <a name="output_computer_name"></a> [computer\_name](#output\_computer\_name) | The OS-level computer name of the virtual machine. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | FQDN of the virtual machine, |
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
| [azurerm_backup_protected_vm.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) | resource |
| [azurerm_dev_test_global_vm_shutdown_schedule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule) | resource |
| [azurerm_linux_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_monitor_data_collection_rule_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine_data_disk_attachment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.lin-diag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_aadlogin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_azdependencyagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_azmonitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_aznetworkwatcheragent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.main_azpolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.win-diag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
