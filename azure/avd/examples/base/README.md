<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region to use | `string` | `"UK South"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `list(string)` | <pre>[<br>  "az-lbs-avd_ext-network-p-rg",<br>  "az-lbs-avd_ext-appattach-p-rg",<br>  "az-lbs-avd_ext-gal-p-rg",<br>  "az-lbs-avd_ext-it-p-rg",<br>  "az-lbs-avd_ext-vdpool-p-rg001",<br>  "az-lbs-avd_ext-vdscaling-p-rg",<br>  "az-lbs-avd_ext-log-p-rg001",<br>  "az-lbs-avd_ext-vdpool-v-rg001"<br>]</pre> | no |

## Outputs

No outputs.

## Resources

No resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_image-gallery"></a> [image-gallery](#module\_image-gallery) | ../../modules/computer-gallery | n/a |
| <a name="module_nsg"></a> [nsg](#module\_nsg) | ../../modules/nsg | n/a |
| <a name="module_nsg-association-it001"></a> [nsg-association-it001](#module\_nsg-association-it001) | ../../modules/nsg-association | n/a |
| <a name="module_nsg-association-st001"></a> [nsg-association-st001](#module\_nsg-association-st001) | ../../modules/nsg-association | n/a |
| <a name="module_nsg-association-vdpool001"></a> [nsg-association-vdpool001](#module\_nsg-association-vdpool001) | ../../modules/nsg-association | n/a |
| <a name="module_nsg-association-vdpool002"></a> [nsg-association-vdpool002](#module\_nsg-association-vdpool002) | ../../modules/nsg-association | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | ../../modules/resourcegroup | n/a |
| <a name="module_storage-appattach"></a> [storage-appattach](#module\_storage-appattach) | ../../modules/storage-account | n/a |
| <a name="module_subnet-it001"></a> [subnet-it001](#module\_subnet-it001) | ../../modules/subnet | n/a |
| <a name="module_subnet-st001"></a> [subnet-st001](#module\_subnet-st001) | ../../modules/subnet | n/a |
| <a name="module_subnet-vdpool001"></a> [subnet-vdpool001](#module\_subnet-vdpool001) | ../../modules/subnet | n/a |
| <a name="module_subnet-vdpool002"></a> [subnet-vdpool002](#module\_subnet-vdpool002) | ../../modules/subnet | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |
<!-- END_TF_DOCS -->