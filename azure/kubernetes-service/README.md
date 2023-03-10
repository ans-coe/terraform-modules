# Terraform Module - Azure - Kubernetes Cluster

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module is used to manage an Azure Kubernetes Cluster with numerous options including support for Azure monitoring and an attached, simple, dedicated ACR (Azure Container Registry). This module is solely focused on the AzureRM configuration and does not work with AzureAD elements such as groups.

Examples can be found under the [examples](./examples/) directory.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the AKS cluster. | `string` | n/a | yes |
| <a name="input_aad_admin_group_object_ids"></a> [aad\_admin\_group\_object\_ids](#input\_aad\_admin\_group\_object\_ids) | Object IDs of AAD Groups that have Admin role over the cluster. These groups will also have read privileges of Azure-level resources. | `list(string)` | `[]` | no |
| <a name="input_aad_tenant_id"></a> [aad\_tenant\_id](#input\_aad\_tenant\_id) | Tenant ID used for AAD RBAC. (defaults to current tenant) | `string` | `null` | no |
| <a name="input_allowed_maintenance_windows"></a> [allowed\_maintenance\_windows](#input\_allowed\_maintenance\_windows) | A list of objects of maintance windows using a day and list of acceptable hours. | <pre>list(object({<br>    day   = string<br>    hours = optional(list(number), [21])<br>  }))</pre> | `null` | no |
| <a name="input_authorized_ip_ranges"></a> [authorized\_ip\_ranges](#input\_authorized\_ip\_ranges) | CIDRs authorized to communicate with the API Server. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_auto_scaler_profile"></a> [auto\_scaler\_profile](#input\_auto\_scaler\_profile) | Autoscaler config. | `map(any)` | `{}` | no |
| <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade) | Upgrade channel for the Kubernetes cluster. | `string` | `null` | no |
| <a name="input_azure_keyvault_secrets_provider_config"></a> [azure\_keyvault\_secrets\_provider\_config](#input\_azure\_keyvault\_secrets\_provider\_config) | Object containing configuration for the Azure Keyvault secrets provider plugin. | <pre>object({<br>    enable_secret_rotation = optional(bool, true)<br>    rotation_interval      = optional(string, "2m")<br>  })</pre> | <pre>{<br>  "enable_secret_rotation": true<br>}</pre> | no |
| <a name="input_cluster_identity"></a> [cluster\_identity](#input\_cluster\_identity) | Cluster identity config. | <pre>object({<br>    id           = string<br>    principal_id = string<br>  })</pre> | `null` | no |
| <a name="input_default_node_pool_name"></a> [default\_node\_pool\_name](#input\_default\_node\_pool\_name) | Name of the default node pool. | `string` | `"default"` | no |
| <a name="input_enable_azure_keyvault_secrets_provider"></a> [enable\_azure\_keyvault\_secrets\_provider](#input\_enable\_azure\_keyvault\_secrets\_provider) | Enable the Azure Keyvault secrets provider plugin. | `bool` | `false` | no |
| <a name="input_enable_azure_policy"></a> [enable\_azure\_policy](#input\_enable\_azure\_policy) | Enable the Azure Policy plugin. | `bool` | `false` | no |
| <a name="input_enable_http_application_routing"></a> [enable\_http\_application\_routing](#input\_enable\_http\_application\_routing) | Enable the HTTP Application Routing plugin. | `bool` | `false` | no |
| <a name="input_enable_ingress_application_gateway"></a> [enable\_ingress\_application\_gateway](#input\_enable\_ingress\_application\_gateway) | Enable the ingress application gateway plugin. | `bool` | `false` | no |
| <a name="input_enable_open_service_mesh"></a> [enable\_open\_service\_mesh](#input\_enable\_open\_service\_mesh) | Enable the Open Service Mesh plugin. | `bool` | `false` | no |
| <a name="input_enable_private_cluster"></a> [enable\_private\_cluster](#input\_enable\_private\_cluster) | Enable AKS private cluster. | `bool` | `false` | no |
| <a name="input_ingress_application_gateway_id"></a> [ingress\_application\_gateway\_id](#input\_ingress\_application\_gateway\_id) | The ID of an existing Application Gateway to integrate with AKS. | `string` | `null` | no |
| <a name="input_ingress_application_gateway_name"></a> [ingress\_application\_gateway\_name](#input\_ingress\_application\_gateway\_name) | The name of an Application Gateway to integrate with AKS or create in the Nodepool resource group. | `string` | `null` | no |
| <a name="input_ingress_application_subnet_cidr"></a> [ingress\_application\_subnet\_cidr](#input\_ingress\_application\_subnet\_cidr) | The CIDR used when creating an Application Gateway. | `string` | `null` | no |
| <a name="input_ingress_application_subnet_id"></a> [ingress\_application\_subnet\_id](#input\_ingress\_application\_subnet\_id) | The ID of the Subnet the Application Gateway will be created on. | `string` | `null` | no |
| <a name="input_kubelet_identity"></a> [kubelet\_identity](#input\_kubelet\_identity) | Kubelet identity config. | <pre>object({<br>    id           = string<br>    principal_id = string<br>    client_id    = string<br>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes to use in the cluster. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_log_analytics_id"></a> [log\_analytics\_id](#input\_log\_analytics\_id) | Log analytics workspace ID to use if providing an existing workspace. | `string` | `null` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Network policy that should be used. ('calico' or 'azure') | `string` | `null` | no |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Additional default node pool configuration not covered by base variables. | `map(any)` | `{}` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Default number of nodes in the default node pool or minimum number of nodes. | `number` | `2` | no |
| <a name="input_node_count_max"></a> [node\_count\_max](#input\_node\_count\_max) | Maximum number of nodes in the AKS cluster. node\_count\_min must also be set for this to function. | `number` | `null` | no |
| <a name="input_node_critical_addons_only"></a> [node\_critical\_addons\_only](#input\_node\_critical\_addons\_only) | Taint the default node pool with 'CriticalAddonsOnly=true:NoSchedule'. | `bool` | `false` | no |
| <a name="input_node_labels"></a> [node\_labels](#input\_node\_labels) | Node labels to apply to the default node pool. | `map(string)` | `null` | no |
| <a name="input_node_size"></a> [node\_size](#input\_node\_size) | Size of nodes in the default node pool. | `string` | `"Standard_B2ms"` | no |
| <a name="input_node_subnet_id"></a> [node\_subnet\_id](#input\_node\_subnet\_id) | Subnet ID to use with default node pool nodes for Azure CNI. | `string` | `null` | no |
| <a name="input_node_zones"></a> [node\_zones](#input\_node\_zones) | Availability zones nodes should be placed in. | `list(number)` | <pre>[<br>  1,<br>  2,<br>  3<br>]</pre> | no |
| <a name="input_pod_subnet_id"></a> [pod\_subnet\_id](#input\_pod\_subnet\_id) | Subnet ID to use with default node pool pods for Azure CNI. | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The Private DNS Zone ID - can alternatively by System to be AKS-managed or None to bring your own DNS. | `string` | `"System"` | no |
| <a name="input_registry_ids"></a> [registry\_ids](#input\_registry\_ids) | List of registry IDs to give this cluster AcrPull access to. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | Service CIDR for AKS. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier of AKS. | `string` | `"Free"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_use_azure_cni"></a> [use\_azure\_cni](#input\_use\_azure\_cni) | Use Azure CNI. | `bool` | `false` | no |
| <a name="input_use_log_analytics"></a> [use\_log\_analytics](#input\_use\_log\_analytics) | Use Log Analytics for monitoring the deployed resources. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the AKS cluster. |
| <a name="output_identity"></a> [identity](#output\_identity) | AKS cluster identity. |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | AKS cluster host. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | AKS cluster kubelet identity. |
| <a name="output_location"></a> [location](#output\_location) | Location of the AKS cluster. |
| <a name="output_log_analytics_id"></a> [log\_analytics\_id](#output\_log\_analytics\_id) | ID of the log analytics. |
| <a name="output_name"></a> [name](#output\_name) | Name of the AKS cluster. |
| <a name="output_node_resource_group_name"></a> [node\_resource\_group\_name](#output\_node\_resource\_group\_name) | Name of the AKS cluster resource group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.main_acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_aks_cluster_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_aks_node_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_aks_pod_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_aks_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.main_log_analytics_read](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_kubernetes_service_versions.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
