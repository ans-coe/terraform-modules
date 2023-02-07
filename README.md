# Terraform Modules

This repository contains a number of Terraform modules for different platforms. At their current scope they are currently being held in a monorepo however any larger modules will utilize a submodule to point to a particular module as a record.

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
|[acr](./azure/acr/README.md)|azure|
|[aks](./azure/aks/README.md)|azure|
|[bastion](./azure/bastion/README.md)|azure|
|[linux-functionapp](./azure/linux-functionapp/README.md)|azure|
|[linux-webapp](./azure/linux-webapp/README.md)|azure|
|[policy-baseline](./azure/policy-baseline/README.md)|azure|
|[power-management](./azure/power-management/README.md)|azure|
|[terraform-ops](./azure/terraform-ops/README.md)|azure|
|[vnet](./azure/vnet/README.md)|azure|
|[project](./azuredevops/project/README.md)|azuredevops|
|[repository](./github/repository/README.md)|github|
