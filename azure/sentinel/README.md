# Terraform (Module) - Azure - Sentinel

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module deploys Azure Sentinel to an exsisting or new Log Analytics Workspace.

If an existing Log Analytics Workspace ID is not provided then a log_analytics_workspace_name will be required to create a new Log Analytics Workspace:

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.78 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_cloud_app_security_config"></a> [cloud\_app\_security\_config](#input\_cloud\_app\_security\_config) | Configuration for the Microsoft 365 Defender Data Connector | <pre>object({<br>    alerts_enabled         = optional(bool, true)<br>    discovery_logs_enabled = optional(bool, true)<br>  })</pre> | <pre>{<br>  "alerts_enabled": true,<br>  "discovery_logs_enabled": true<br>}</pre> | no |
| <a name="input_customer_managed_key_enabled"></a> [customer\_managed\_key\_enabled](#input\_customer\_managed\_key\_enabled) | pecifies if the Workspace is using Customer managed key. Defaults to false. Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_dc_ad_enabled"></a> [dc\_ad\_enabled](#input\_dc\_ad\_enabled) | Enable the Data Connector: Azure Active Directory | `bool` | `false` | no |
| <a name="input_dc_advanced_threat_protection_enabled"></a> [dc\_advanced\_threat\_protection\_enabled](#input\_dc\_advanced\_threat\_protection\_enabled) | Enable the Data Connector: Azure Active Directory Identity Protection | `bool` | `false` | no |
| <a name="input_dc_microsoft_cloud_app_security_enabled"></a> [dc\_microsoft\_cloud\_app\_security\_enabled](#input\_dc\_microsoft\_cloud\_app\_security\_enabled) | Enable the Data Connector: Microsoft 365 Defender | `bool` | `false` | no |
| <a name="input_dc_microsoft_defender_advanced_threat_protection_enabled"></a> [dc\_microsoft\_defender\_advanced\_threat\_protection\_enabled](#input\_dc\_microsoft\_defender\_advanced\_threat\_protection\_enabled) | Enable the Data Connector: Microsoft Defender Advanced Threat Protection | `bool` | `false` | no |
| <a name="input_dc_microsoft_threat_intelligence_enabled"></a> [dc\_microsoft\_threat\_intelligence\_enabled](#input\_dc\_microsoft\_threat\_intelligence\_enabled) | Enable the Data Connector: Threat Intelligence | `bool` | `false` | no |
| <a name="input_dc_microsoft_threat_protection_enabled"></a> [dc\_microsoft\_threat\_protection\_enabled](#input\_dc\_microsoft\_threat\_protection\_enabled) | Enable the Data Connector: Microsoft Threat Protection | `bool` | `false` | no |
| <a name="input_dc_office_365_enabled"></a> [dc\_office\_365\_enabled](#input\_dc\_office\_365\_enabled) | Enable the Data Connector: Office 365 | `bool` | `false` | no |
| <a name="input_dc_security_center_enabled"></a> [dc\_security\_center\_enabled](#input\_dc\_security\_center\_enabled) | Enable the Data Connector: Azure Security Centre | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The region in which resources will be created | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The id of an existing Log Anylitics Workspace | `string` | `null` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of the new Log Anylitics Workspace to be created | `string` | `null` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | The SKU of the Log Analytics Workspace | `string` | `"PerGB2018"` | no |
| <a name="input_microsoft_threat_intelligence_feed_lookback_date"></a> [microsoft\_threat\_intelligence\_feed\_lookback\_date](#input\_microsoft\_threat\_intelligence\_feed\_lookback\_date) | The lookback date for the Microsoft Emerging Threat Feed in RFC3339. Changing this forces a new Data Connector to be created. | `string` | `"1970-01-01T00:00:00Z"` | no |
| <a name="input_office_365_config"></a> [office\_365\_config](#input\_office\_365\_config) | Configuration for the Office 365 Data Connector | <pre>object({<br>    exchange_enabled   = optional(bool, true)<br>    sharepoint_enabled = optional(bool, true)<br>    teams_enabled      = optional(bool, true)<br>  })</pre> | <pre>{<br>  "exchange_enabled": true,<br>  "sharepoint_enabled": true,<br>  "teams_enabled": true<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_sentinel_id"></a> [azure\_sentinel\_id](#output\_azure\_sentinel\_id) | n/a |
| <a name="output_dc_ad_id"></a> [dc\_ad\_id](#output\_dc\_ad\_id) | n/a |
| <a name="output_dc_advanced_threat_protection_id"></a> [dc\_advanced\_threat\_protection\_id](#output\_dc\_advanced\_threat\_protection\_id) | n/a |
| <a name="output_dc_microsoft_cloud_app_security_id"></a> [dc\_microsoft\_cloud\_app\_security\_id](#output\_dc\_microsoft\_cloud\_app\_security\_id) | n/a |
| <a name="output_dc_microsoft_defender_advanced_threat_protection_id"></a> [dc\_microsoft\_defender\_advanced\_threat\_protection\_id](#output\_dc\_microsoft\_defender\_advanced\_threat\_protection\_id) | n/a |
| <a name="output_dc_microsoft_threat_intelligence_id"></a> [dc\_microsoft\_threat\_intelligence\_id](#output\_dc\_microsoft\_threat\_intelligence\_id) | n/a |
| <a name="output_dc_microsoft_threat_protection_id"></a> [dc\_microsoft\_threat\_protection\_id](#output\_dc\_microsoft\_threat\_protection\_id) | n/a |
| <a name="output_dc_office_365_id"></a> [dc\_office\_365\_id](#output\_dc\_office\_365\_id) | n/a |
| <a name="output_dc_security_center_id"></a> [dc\_security\_center\_id](#output\_dc\_security\_center\_id) | n/a |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_sentinel_data_connector_azure_active_directory.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_azure_active_directory) | resource |
| [azurerm_sentinel_data_connector_azure_advanced_threat_protection.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_azure_advanced_threat_protection) | resource |
| [azurerm_sentinel_data_connector_azure_security_center.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_azure_security_center) | resource |
| [azurerm_sentinel_data_connector_microsoft_cloud_app_security.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_microsoft_cloud_app_security) | resource |
| [azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_microsoft_defender_advanced_threat_protection) | resource |
| [azurerm_sentinel_data_connector_microsoft_threat_intelligence.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_microsoft_threat_intelligence) | resource |
| [azurerm_sentinel_data_connector_microsoft_threat_protection.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_microsoft_threat_protection) | resource |
| [azurerm_sentinel_data_connector_office_365.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_office_365) | resource |
| [azurerm_sentinel_log_analytics_workspace_onboarding.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_log_analytics_workspace_onboarding) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |