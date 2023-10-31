# Example - Hub - Advanced

This example deploys a hub network with two spoke networks.  A Firewall, Bastion, a Virtual Network Gateway and Private DNS Resolver are also configured as part of the deployment

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Inputs

No inputs.

## Outputs

No outputs.

## Resources

No resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firewall-policy"></a> [firewall-policy](#module\_firewall-policy) | ../../../firewall-policy | n/a |
| <a name="module_hub"></a> [hub](#module\_hub) | ../../ | n/a |
| <a name="module_spoke_mgmt"></a> [spoke\_mgmt](#module\_spoke\_mgmt) | ../../../spoke | n/a |
| <a name="module_spoke_prd"></a> [spoke\_prd](#module\_spoke\_prd) | ../../../spoke | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |