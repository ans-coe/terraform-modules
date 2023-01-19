# Terraform - CHANGE_ME

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
- If you are not using pre-commit/this module won't have a dedicated repository, remove [.pre-commit-config.yaml](./.pre-commit-config.yaml)
  - If you are keeping this, make sure you have installed [pre-commit](https://pre-commit.com/), [terraform-docs](https://terraform-docs.io/), [tfsec](https://github.com/aquasecurity/tfsec) and [tflint](https://github.com/terraform-linters/tflint) or have removed those specific hooks.
- If using this for Terraform Configurations, optionally remove [examples](./examples/) and remove `.terraform.lock.hcl` from the [.gitignore](./.gitignore)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Inputs

No inputs.

## Outputs

No outputs.

## Resources

No resources.

## Modules

No modules.
<!-- END_TF_DOCS -->
