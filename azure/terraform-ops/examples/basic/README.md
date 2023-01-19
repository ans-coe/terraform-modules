# Example - Basic

This example is used to illustrate the basic usage of this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location of this deployment. | `string` | `"uksouth"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags given to the resources created by this template. | `map(string)` | <pre>{<br>  "example": "basic",<br>  "module": "terraform-ops",<br>  "usage": "demo"<br>}</pre> | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [http_http.my_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_example"></a> [example](#module\_example) | ../../ | n/a |
<!-- END_TF_DOCS -->
