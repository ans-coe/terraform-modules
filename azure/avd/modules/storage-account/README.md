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
| <a name="input_location"></a> [location](#input\_location) | Azure location | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the storage account. Only lowercase Alphanumeric characters allowed. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Project Owner | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Project service tier | `number` | n/a | yes |
| <a name="input_support_contact"></a> [support\_contact](#input\_support\_contact) | Support Contact | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Project workload name | `string` | n/a | yes |
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Defines the access tier for `BlobStorage`, `FileStorage` and `StorageV2` accounts. Valid options are `Hot` and `Cool`, defaults to `Hot`. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Defines the Kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Changing this forces a new resource to be created. Defaults to StorageV2. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Defines the type of replication to use for this Storage Account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. | `string` | `"ZRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Defines the Tier to use for this Storage Account. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created. | `string` | `"Standard"` | no |
| <a name="input_advanced_threat_protection_enabled"></a> [advanced\_threat\_protection\_enabled](#input\_advanced\_threat\_protection\_enabled) | Boolean flag which controls if advanced threat protection is enabled, see [documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-advanced-threat-protection?tabs=azure-portal) for more information. | `bool` | `false` | no |
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | List of CIDR to allow access to that Storage Account. | `list(string)` | `[]` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | List of objects to create some Blob containers in this Storage Account. | <pre>list(object({<br>    name                  = string<br>    container_access_type = optional(string, "private")<br>    metadata              = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_cross_tenant_replication_enabled"></a> [cross\_tenant\_replication\_enabled](#input\_cross\_tenant\_replication\_enabled) | Enable cross tenant replication. | `bool` | `false` | no |
| <a name="input_custom_diagnostic_settings_name"></a> [custom\_diagnostic\_settings\_name](#input\_custom\_diagnostic\_settings\_name) | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | The Custom Domain Name to use for the Storage Account, which will be validated by Azure. | `string` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer Managed Key. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#customer_managed_key) for more information. | <pre>object({<br>    key_vault_key_id          = optional(string, null)<br>    managed_hsm_key_id        = optional(string, null)<br>    user_assigned_identity_id = string<br>  })</pre> | `null` | no |
| <a name="input_default_firewall_action"></a> [default\_firewall\_action](#input\_default\_firewall\_action) | Which default firewalling policy to apply. Valid values are `Allow` or `Deny`. | `string` | `"Deny"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Base tagging | `map(string)` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| <a name="input_file_share_authentication"></a> [file\_share\_authentication](#input\_file\_share\_authentication) | Storage Account file shares authentication configuration. | <pre>object({<br>    directory_type = string<br>    active_directory = optional(object({<br>      storage_sid         = string<br>      domain_name         = string<br>      domain_sid          = string<br>      domain_guid         = string<br>      forest_name         = string<br>      netbios_domain_name = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_file_share_cors_rules"></a> [file\_share\_cors\_rules](#input\_file\_share\_cors\_rules) | Storage Account file shares CORS rule. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information. | <pre>object({<br>    allowed_headers    = list(string)<br>    allowed_methods    = list(string)<br>    allowed_origins    = list(string)<br>    exposed_headers    = list(string)<br>    max_age_in_seconds = number<br>  })</pre> | `null` | no |
| <a name="input_file_share_properties_smb"></a> [file\_share\_properties\_smb](#input\_file\_share\_properties\_smb) | Storage Account file shares smb properties. | <pre>object({<br>    versions                        = optional(list(string), null)<br>    authentication_types            = optional(list(string), null)<br>    kerberos_ticket_encryption_type = optional(list(string), null)<br>    channel_encryption_type         = optional(list(string), null)<br>    multichannel_enabled            = optional(bool, null)<br>  })</pre> | `null` | no |
| <a name="input_file_share_retention_policy_in_days"></a> [file\_share\_retention\_policy\_in\_days](#input\_file\_share\_retention\_policy\_in\_days) | Storage Account file shares retention policy in days. Enabling this may require additional directory permissions. | `number` | `null` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | List of objects to create some File Shares in this Storage Account. | <pre>list(object({<br>    name             = string<br>    quota_in_gb      = number<br>    enabled_protocol = optional(string)<br>    metadata         = optional(map(string))<br>    acl = optional(list(object({<br>      id          = string<br>      permissions = string<br>      start       = optional(string)<br>      expiry      = optional(string)<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_hns_enabled"></a> [hns\_enabled](#input\_hns\_enabled) | Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 and must be `true` if `nfsv3_enabled` or `sftp_enabled` is set to `true`. Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_https_traffic_only_enabled"></a> [https\_traffic\_only\_enabled](#input\_https\_traffic\_only\_enabled) | Boolean flag which forces HTTPS if enabled. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account. | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | `string` | `"SystemAssigned"` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Boolean flag which enables infrastructure encryption.  Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#infrastructure_encryption_enabled) for more information. | `bool` | `false` | no |
| <a name="input_logs_categories"></a> [logs\_categories](#input\_logs\_categories) | Log categories to send to destinations. | `list(string)` | `null` | no |
| <a name="input_logs_metrics_categories"></a> [logs\_metrics\_categories](#input\_logs\_metrics\_categories) | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | The minimum supported TLS version for the Storage Account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. | `string` | `"TLS1_2"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional prefix for the generated name | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix for the generated name | `string` | `""` | no |
| <a name="input_network_bypass"></a> [network\_bypass](#input\_network\_bypass) | Specifies whether traffic is bypassed for 'Logging', 'Metrics', 'AzureServices' or 'None'. | `list(string)` | <pre>[<br>  "Logging",<br>  "Metrics",<br>  "AzureServices"<br>]</pre> | no |
| <a name="input_network_rules_enabled"></a> [network\_rules\_enabled](#input\_network\_rules\_enabled) | Boolean to enable Network Rules on the Storage Account, requires `network_bypass`, `allowed_cidrs`, `subnet_ids` or `default_firewall_action` correctly set if enabled. | `bool` | `true` | no |
| <a name="input_nfsv3_enabled"></a> [nfsv3\_enabled](#input\_nfsv3\_enabled) | Is NFSv3 protocol enabled? Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_private_link_access"></a> [private\_link\_access](#input\_private\_link\_access) | List of Privatelink objects to allow access from. | <pre>list(object({<br>    endpoint_resource_id = string<br>    endpoint_tenant_id   = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_public_nested_items_allowed"></a> [public\_nested\_items\_allowed](#input\_public\_nested\_items\_allowed) | Allow or disallow nested items within this Account to opt into being public. | `bool` | `false` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the public network access is enabled? | `bool` | `true` | no |
| <a name="input_queue_properties_logging"></a> [queue\_properties\_logging](#input\_queue\_properties\_logging) | Logging queue properties | <pre>object({<br>    delete                = optional(bool, true)<br>    read                  = optional(bool, true)<br>    write                 = optional(bool, true)<br>    version               = optional(string, "1.0")<br>    retention_policy_days = optional(number, 10)<br>  })</pre> | `{}` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | List of objects to create some Queues in this Storage Account. | <pre>list(object({<br>    name     = string<br>    metadata = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_sftp_enabled"></a> [sftp\_enabled](#input\_sftp\_enabled) | Is SFTP enabled? | `bool` | `false` | no |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Indicates whether the Storage Account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). | `bool` | `true` | no |
| <a name="input_static_website_config"></a> [static\_website\_config](#input\_static\_website\_config) | Static website configuration. Can only be set when the `account_kind` is set to `StorageV2` or `BlockBlobStorage`. | <pre>object({<br>    index_document     = optional(string)<br>    error_404_document = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_storage_account_custom_name"></a> [storage\_account\_custom\_name](#input\_storage\_account\_custom\_name) | Custom Azure Storage Account name, generated if not set | `string` | `""` | no |
| <a name="input_storage_blob_cors_rules"></a> [storage\_blob\_cors\_rules](#input\_storage\_blob\_cors\_rules) | Storage Account blob CORS rules. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information. | <pre>list(object({<br>    allowed_headers    = list(string)<br>    allowed_methods    = list(string)<br>    allowed_origins    = list(string)<br>    exposed_headers    = list(string)<br>    max_age_in_seconds = number<br>  }))</pre> | `[]` | no |
| <a name="input_storage_blob_data_protection"></a> [storage\_blob\_data\_protection](#input\_storage\_blob\_data\_protection) | Storage account blob Data protection parameters. | <pre>object({<br>    change_feed_enabled                       = optional(bool, false)<br>    versioning_enabled                        = optional(bool, false)<br>    last_access_time_enabled                  = optional(bool, false)<br>    delete_retention_policy_in_days           = optional(number, 0)<br>    container_delete_retention_policy_in_days = optional(number, 0)<br>    container_point_in_time_restore           = optional(bool, false)<br>  })</pre> | <pre>{<br>  "change_feed_enabled": true,<br>  "container_delete_retention_policy_in_days": 30,<br>  "container_point_in_time_restore": true,<br>  "delete_retention_policy_in_days": 30,<br>  "last_access_time_enabled": true,<br>  "versioning_enabled": true<br>}</pre> | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets to allow access to that Storage Account. | `list(string)` | `[]` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | List of objects to create some Tables in this Storage Account. | <pre>list(object({<br>    name = string<br>    acl = optional(list(object({<br>      id          = string<br>      permissions = string<br>      start       = optional(string)<br>      expiry      = optional(string)<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_use_caf_naming"></a> [use\_caf\_naming](#input\_use\_caf\_naming) | Use the Azure CAF naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| <a name="input_use_subdomain"></a> [use\_subdomain](#input\_use\_subdomain) | Should the Custom Domain Name be validated by using indirect CNAME validation? | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | Created Storage Account ID. |
| <a name="output_storage_account_identity"></a> [storage\_account\_identity](#output\_storage\_account\_identity) | Created Storage Account identity block. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Created Storage Account name. |
| <a name="output_storage_account_properties"></a> [storage\_account\_properties](#output\_storage\_account\_properties) | Created Storage Account properties. |
| <a name="output_storage_blob_containers"></a> [storage\_blob\_containers](#output\_storage\_blob\_containers) | Created blob containers in the Storage Account. |
| <a name="output_storage_file_queues"></a> [storage\_file\_queues](#output\_storage\_file\_queues) | Created queues in the Storage Account. |
| <a name="output_storage_file_shares"></a> [storage\_file\_shares](#output\_storage\_file\_shares) | Created file shares in the Storage Account. |
| <a name="output_storage_file_tables"></a> [storage\_file\_tables](#output\_storage\_file\_tables) | Created tables in the Storage Account. |

## Resources

| Name | Type |
|------|------|
| [azurerm_advanced_threat_protection.threat_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/advanced_threat_protection) | resource |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.network_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->