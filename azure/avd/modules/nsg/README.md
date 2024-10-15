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
| <a name="input_location"></a> [location](#input\_location) | The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The Name which should be used for this Network Security Group. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | "A list of security rules to add to the security group. Each rule should be a map of values to add. See the Readme.md file for further details."<br>    security\_rules = {<br>      name : "The name of the security rule."<br>      priority : "Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule."<br>      direction : "A description for this rule. Restricted to 140 characters."<br>      access : "Specifies whether network traffic is allowed or denied. Possible values are 'Allow' and 'Deny'."<br>      protocol : "Network protocol this rule applies to. Possible values include 'Tcp', 'Udp', 'Icmp', 'Esp', 'Ah' or '*' (which matches all)."<br>      source\_port\_range : "Source Port or Range. Integer or range between '0' and '65535' or '*' to match any. This is required if 'source\_port\_ranges' is not specified."<br>      source\_port\_ranges : "List of source ports or port ranges. This is required if 'source\_port\_range' is not specified."<br>      destination\_port\_range : "Destination Port or Range. Integer or range between '0' and '65535' or '*' to match any. This is required if 'destination\_port\_ranges' is not specified."<br>      destination\_port\_ranges : "List of destination ports or port ranges. This is required if 'destination\_port\_range' is not specified."<br>      source\_address\_prefix : "'CIDR 'or 'source IP range' or '*' to match any IP. Tags such as 'VirtualNetwork', 'AzureLoadBalancer' and 'Internet' can also be used. This is required if 'source\_address\_prefixes' is not specified."<br>      source\_address\_prefixes : "List of source address prefixes. Tags may not be used. This is required if 'source\_address\_prefix' is not specified."<br>      destination\_address\_prefix : "'CIDR' or 'destination IP range' or '*' to match any IP. Tags such as 'VirtualNetwork', 'AzureLoadBalancer' and 'Internet' can also be used. This is required if 'destination\_address\_prefixes' is not specified."<br>      destination\_address\_prefixes : "List of destination address prefixes. Tags may not be used. This is required if 'destination\_address\_prefix' is not specified."<br>      source\_application\_security\_group\_ids : "A List of source Application Security Group IDs."<br>      destination\_application\_security\_group\_ids : "A List of destination Application Security Group IDs."<br>    } | `any` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | The ID of the newly created Network Security Group |
| <a name="output_nsg_name"></a> [nsg\_name](#output\_nsg\_name) | The name of the newly created Network Security Group |
| <a name="output_nsg_rules"></a> [nsg\_rules](#output\_nsg\_rules) | The name of the newly created Network Security Group |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->