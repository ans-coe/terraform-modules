# Terraform (Module) - PLATFORM - NAME

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This document will describe what the module is for and what is contained in it. It will be generated using [terraform-docs](https://terraform-docs.io/) which is configured to append to the existing README.md file.

Things to update:
- README.md header
- README.md header content - description of module and its purpose
- Update [terraform.tf](terraform.tf) required_versions
- Add a LICENSE to this module
- Update .tflint.hcl plugins if necessary
- If this module is to be created for use with Terraform Registry, ensure the repository itself is called `terraform-PROVIDER-NAME` for the publish step
- If this module is going to be a part of a monorepo, remove [.pre-commit-config.yaml](./.pre-commit-config.yaml)
- If using this for Terraform Configurations, optionally remove [examples](./examples/) and remove `.terraform.lock.hcl` from the [.gitignore](./.gitignore)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.22 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_policies"></a> [firewall\_policies](#input\_firewall\_policies) | List of Firewall Policies | <pre>map(object({<br>    name                     = string<br>    sku                      = string<br>    base_policy_id           = string<br>    threat_intelligence_mode = string<br>    dns = optional(object({<br>      servers       = optional(list(string))<br>      proxy_enabled = optional(bool)<br>    }))<br>    threat_intelligence_allow_list = optional(object({<br>      ip_addresses = list(string)<br>      fqdns        = list(string)<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_firewall_policy_rule_collection_groups"></a> [firewall\_policy\_rule\_collection\_groups](#input\_firewall\_policy\_rule\_collection\_groups) | Firewall Rule Collection Groups, Collections and Rules | <pre>map(object({<br>    name               = string<br>    firewall_policy_id = string<br>    priority           = string<br><br>    application_rule_collection = optional(map(object({<br>      name        = string<br>      description = optional(string)<br>      action      = string<br>      priority    = string<br>      rule = map(object({<br>        name = string<br>        protocols = optional(map(object({<br>          type = string<br>          port = string<br>        })))<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_urls      = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_fqdn_tags = optional(list(string))<br>      }))<br>    })))<br><br>    network_rule_collection = optional(map(object({<br>      name        = string<br>      description = optional(string)<br>      action      = string<br>      priority    = string<br>      rule = map(object({<br>        name                  = string<br>        protocols             = list(string) #Any, TCP, UDP, ICMP<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_ip_groups = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_ports     = list(string)<br>      }))<br>    })))<br><br>    nat_rule_collection = optional(map(object({<br>      name        = string<br>      description = optional(string)<br>      priority    = string<br>      action      = string<br>      rule = map(object({<br>        name                = string<br>        protocols           = list(string) #TCP or UDP<br>        source_addresses    = optional(list(string))<br>        source_ip_groups    = optional(list(string))<br>        destination_address = optional(string)<br>        destination_ports   = optional(list(string))<br>        translated_address  = optional(string)<br>        translated_fqdn     = optional(string)<br>        translated_port     = string<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall_policy.firewall-policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_firewall_policy_rule_collection_groups.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_groups) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |