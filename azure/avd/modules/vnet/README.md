<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.68.0 |

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
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Virtual Network | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | The address space that is used the virtual network. You can supply more than one address space | `list(string)` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_bgp_community"></a> [virtual\_network\_bgp\_community](#input\_virtual\_network\_bgp\_community) | The BGP community attribute in format `<as-number>:<community-value>`. The as-number segment is the Microsoft ASN, which is always 12076 for now. | `string` | `null` | no |
| <a name="input_virtual_network_ddos_protection_plan"></a> [virtual\_network\_ddos\_protection\_plan](#input\_virtual\_network\_ddos\_protection\_plan) | "AzureNetwork DDoS Protection Plan. This is optional, but when specified, the below attributes are required"<br>  "id - The ID of DDoS Protection Plan."<br>  "enable - Enable/disable DDoS Protection Plan on Virtual Network." | <pre>object({<br>    enable = optional(bool, true)<br>    id     = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_virtual_network_dns_servers"></a> [virtual\_network\_dns\_servers](#input\_virtual\_network\_dns\_servers) | List of IP addresses of DNS servers | `list(string)` | `[]` | no |
| <a name="input_virtual_network_edge_zone"></a> [virtual\_network\_edge\_zone](#input\_virtual\_network\_edge\_zone) | Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. Changing this forces a new Virtual Network to be created. | `string` | `null` | no |
| <a name="input_virtual_network_flow_timeout_in_minutes"></a> [virtual\_network\_flow\_timeout\_in\_minutes](#input\_virtual\_network\_flow\_timeout\_in\_minutes) | The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between `4` and `30`minutes. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_location"></a> [location](#output\_location) | Virtual Network location |
| <a name="output_virtual_network_guid"></a> [virtual\_network\_guid](#output\_virtual\_network\_guid) | Virtual Network GUID |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | Virtual Network Identity |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | Virtual Network Name |

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->