# Terraform Modules

This repository contains a number of Terraform modules for different platforms. At their current scope they are currently being held in a monorepo however any mature modules will utilize a submodule to point to a particular module as a record.

These modules should be suitable to use in production but we anticipate that there will be dramatic shifts in functionality made to these along the way. Therefore it's highly recommended that if you're planning to use these modules, you specifically refer to the commit. EG:

```hcl
module "example" {
  source = "git::https://github.com/ans-coe/terraform-modules.git//azure/windows-virtual-machine/?ref=745f0256ad0499aefe97f7b2a8b7e6027ec92e88"
}
```

## Usage

All modules should contain at least a basic example and documentation.

To create a new module, simply copy the module template, for example like below:

```bash
cp -r _template kube/tools
```

## Modules

Below is a list of available modules linking directly to the root README.md.

|Module|Type|
|-|-|
|[_template](./_template/README.md)|repo template|
|[application-gateway](./azure/application-gateway/README.md)|azure|
|[bastion](https://github.com/ans-coe/terraform-azurerm-bastion/blob/main//README.md)|azure|
|[container-registry](./azure/container-registry/README.md)|azure|
|[kubernetes-service](./azure/kubernetes-service/README.md)|azure|
|[linux-functionapp](./azure/linux-functionapp/README.md)|azure|
|[linux-virtual-machine](./azure/linux-virtual-machine/README.md)|azure|
|[linux-webapp](./azure/linux-webapp/README.md)|azure|
|[network-security-group](./azure/network-security-group/README.md)|azure|
|[policy-baseline](./azure/policy-baseline/README.md)|azure|
|[power-management](./azure/power-management/README.md)|azure|
|[terraform-ops](./azure/terraform-ops/README.md)|azure|
|[virtual-network](https://github.com/ans-coe/terraform-azurerm-virtual-network/blob/main/README.md)|azure|
|[windows-virtual-machine](./azure/windows-virtual-machine/README.md)|azure|
|[project](./azuredevops/project/README.md)|azuredevops|
|[repository](./github/repository/README.md)|github|
_______________
| Classified  |
| :---------: |
|   PUBLIC    |