# Terraform Module - Azure - Network Security Group

#### Table of Contents

- [Terraform Module - Azure - Network Security Group](#terraform-module---azure---network-security-group)
      - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Resources](#resources)
  - [Modules](#modules)

## Usage

This module creates a network security group with a separate resource and variable used for inbound and outbound rules.

The network security group will be associated to a provided list of subnet ids.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the created network security group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Enable flog log for this network security group. | `bool` | `false` | no |
| <a name="input_flow_log_config"></a> [flow\_log\_config](#input\_flow\_log\_config) | Configuration for flow logs. | <pre>object({<br>    version                             = optional(number, 2)<br>    network_watcher_name                = string<br>    network_watcher_resource_group_name = string<br>    storage_account_id                  = string<br>    retention_days                      = optional(number, 7)<br><br>    enable_analytics           = optional(bool, false)<br>    analytics_interval_minutes = optional(number, 10)<br>    workspace_resource_id      = optional(string)<br>    workspace_region           = optional(string)<br>    workspace_id               = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_priority_interval"></a> [priority\_interval](#input\_priority\_interval) | The interval to use when moving onto the next rules' priority. | `number` | `5` | no |
| <a name="input_rules_inbound"></a> [rules\_inbound](#input\_rules\_inbound) | A list of objects describing a rule inbound. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_rules_outbound"></a> [rules\_outbound](#input\_rules\_outbound) | A list of objects describing a rule outbound. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_start_priority"></a> [start\_priority](#input\_start\_priority) | The priority number to start from when creating rules. | `number` | `1000` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet ids to associate with this NSG. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the network security group. |
| <a name="output_location"></a> [location](#output\_location) | Location of the network security group. |
| <a name="output_name"></a> [name](#output\_name) | Name of the network security group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |
| <a name="output_rules_inbound"></a> [rules\_inbound](#output\_rules\_inbound) | The output of the Inbound NSG rules. |
| <a name="output_rules_outbound"></a> [rules\_outbound](#output\_rules\_outbound) | The output of the Outbound NSG rules. |
| <a name="output_subnet_associations"></a> [subnet\_associations](#output\_subnet\_associations) | The output of the subnets associated with this NSG. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The output of subnet IDs associated with this NSG |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_watcher_flow_log.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_subnet_network_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |