# Terraform (Module) - Azure - Firewall-Policy

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module creates an Azure Firewall Policy along with Rule Collection Groups, Rule Collections and Rules.

Azure Firewall Policies should be created before an Azure Firewall.  The policy id is  associated with the Firewall during the Firewall's creation.

This document will describe what the module is for and what is contained in it. It will be generated using [terraform-docs](https://terraform-docs.io/) which is configured to append to the existing README.md file.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.74 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_base_policy_id"></a> [base\_policy\_id](#input\_base\_policy\_id) | The ID of the base/parent Firewall Policy | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | Whether to enable DNS proxy on Firewalls attached to this Firewall Policy and a list of custom DNS Server IPs | <pre>object({<br>    servers       = optional(list(string))<br>    proxy_enabled = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_insights"></a> [insights](#input\_insights) | Details for configuring a Log Analytics Workspace for the policy. | <pre>object({<br>    enabled   = optional(bool, false)<br>    id        = optional(string)<br>    retention = optional(number, 30)<br><br>    log_analytics_workspace = optional(map(string), {})<br>  })</pre> | `null` | no |
| <a name="input_intrusion_detection"></a> [intrusion\_detection](#input\_intrusion\_detection) | Configuration details for IDPS | <pre>object({<br>    mode                = optional(string, "Alert")<br>    signature_overrides = optional(map(string), {})<br>    traffic_bypass = optional(map(object({<br>      description           = optional(string)<br>      protocol              = string<br>      destination_addresses = optional(list(string))<br>      destination_ip_groups = optional(list(string))<br>      destination_ports     = optional(list(string))<br>      source_addresses      = optional(list(string))<br>      source_ip_groups      = optional(list(string))<br>    })), {})<br>    private_ranges = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_rule_collection_groups"></a> [rule\_collection\_groups](#input\_rule\_collection\_groups) | Rule Collection Groups | <pre>map(object({<br>    priority = number<br><br>    application_rule_collections = optional(map(object({<br>      description = optional(string)<br>      action      = string<br>      priority    = number<br>      rules = map(object({<br>        protocols             = optional(map(string)) #Http, Https<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_urls      = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_fqdn_tags = optional(list(string))<br>      }))<br>    })), {})<br><br>    network_rule_collections = optional(map(object({<br>      description = optional(string)<br>      action      = string<br>      priority    = number<br>      rules = map(object({<br>        protocols             = list(string) #Any, TCP, UDP, ICMP<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_ip_groups = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_ports     = optional(list(string), [])<br>      }))<br>    })), {})<br><br>    nat_rule_collections = optional(map(object({<br>      description = optional(string)<br>      priority    = number<br>      action      = optional(string, "Dnat") #Dnat only<br>      rules = map(object({<br>        protocols           = list(string) #TCP or UDP<br>        source_addresses    = optional(list(string))<br>        source_ip_groups    = optional(list(string))<br>        destination_address = optional(string)<br>        destination_ports   = optional(list(number))<br>        translated_address  = optional(string)<br>        translated_fqdn     = optional(string)<br>        translated_port     = optional(number)<br>      }))<br>    })), {})<br>  }))</pre> | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU Tier of the Firewall Policy. Possible values are Standard, Premium and Basic | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_threat_intelligence_allowlist"></a> [threat\_intelligence\_allowlist](#input\_threat\_intelligence\_allowlist) | A list of FQDNs, IPs or CIDR ranges that will be skipped for threat detection. | <pre>object({<br>    ip_addresses = optional(list(string), [])<br>    fqdns        = optional(list(string), [])<br>  })</pre> | `null` | no |
| <a name="input_threat_intelligence_mode"></a> [threat\_intelligence\_mode](#input\_threat\_intelligence\_mode) | The operation mode for Threat Intelligence. Possible values are Alert, Deny and Off | `string` | `"Alert"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_child_policies"></a> [child\_policies](#output\_child\_policies) | A list of reference to child Firewall Policies of this Firewall Policy. |
| <a name="output_firewalls"></a> [firewalls](#output\_firewalls) | A list of references to Azure Firewalls that this Firewall Policy is associated with. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Azure Firewall Policy. |
| <a name="output_rule_collection_groups"></a> [rule\_collection\_groups](#output\_rule\_collection\_groups) | A list of references to Firewall Policy Rule Collection Groups that belongs to this Firewall Policy. |

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_firewall_policy_rule_collection_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |