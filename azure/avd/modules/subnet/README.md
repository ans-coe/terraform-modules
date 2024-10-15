<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.68.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes) | The address prefixes to use for the subnet. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Subnet | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the name of the resource group in which to create the subnets. Changing this forces new resources to be created. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network to which to attach the subnet. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_delegation_name"></a> [delegation\_name](#input\_delegation\_name) | The name given to the delegation that will be created. | `string` | `null` | no |
| <a name="input_enable_delegation"></a> [enable\_delegation](#input\_enable\_delegation) | Should 'delegation' be enabled for the subnet | `bool` | `false` | no |
| <a name="input_nat_gateway_enabled"></a> [nat\_gateway\_enabled](#input\_nat\_gateway\_enabled) | Should 'NAT Gateway association' be enabled for the subnet. | `bool` | `false` | no |
| <a name="input_nat_gateway_id"></a> [nat\_gateway\_id](#input\_nat\_gateway\_id) | The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_network_security_group_enabled"></a> [network\_security\_group\_enabled](#input\_network\_security\_group\_enabled) | Should 'Network Security Group association' be enabled for the subnet. | `bool` | `false` | no |
| <a name="input_network_security_group_id"></a> [network\_security\_group\_id](#input\_network\_security\_group\_id) | The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_private_link_service_network_policies_enabled"></a> [private\_link\_service\_network\_policies\_enabled](#input\_private\_link\_service\_network\_policies\_enabled) | Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true. | `bool` | `true` | no |
| <a name="input_route_table_enabled"></a> [route\_table\_enabled](#input\_route\_table\_enabled) | Should 'Route Table association' be enabled for the subnet. | `bool` | `false` | no |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | The ID of the Route Table which should be associated with the Subnet. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_service_delegation_actions"></a> [service\_delegation\_actions](#input\_service\_delegation\_actions) | A list of Actions which should be delegated. This list is specific to the service to delegate to. | `list(string)` | `null` | no |
| <a name="input_service_delegation_name"></a> [service\_delegation\_name](#input\_service\_delegation\_name) | The name of the service to whom the subnet should be delegated (e.g. Microsoft.Web/serverFarms) | `string` | `null` | no |
| <a name="input_service_endpoint_policy_ids"></a> [service\_endpoint\_policy\_ids](#input\_service\_endpoint\_policy\_ids) | The list of IDs of Service Endpoint Policies to associate with the subnet. | `list(string)` | `null` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global and Microsoft.Web. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The ID of the subnet created |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | Name of subnet created |

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_network_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->