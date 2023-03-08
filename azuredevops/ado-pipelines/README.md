# Terraform Module - ADO Pipelines

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This terraform config will create the pipelines in ADO for the rest of the projects.

This should be locally ran as it requires a PAT token. 

To run this locally, you'll need to setup PAT tokens to ADO and feed these in as variables. The suggested way to do this is to create a file in the repo called `secret.auto.tfvars` and then put these tokens in this file. 

EG:

```
pat = "xxxxxxxxxxxxx" 
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | >=0.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pat"></a> [pat](#input\_pat) | This is the PAT token to connect to the ADO project | `any` | n/a | yes |
| <a name="input_pipelines"></a> [pipelines](#input\_pipelines) | n/a | <pre>list(object({<br>    pipeline_name = string<br>    pipeline_path = string<br>    yml_path      = string<br>  }))</pre> | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project | `string` | `"Terraform-Ops"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | The name of the repo | `string` | `"terraform-configs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pipelines"></a> [pipelines](#output\_pipelines) | n/a |

## Resources

| Name | Type |
|------|------|
| [azuredevops_build_definition.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition) | resource |
| [azuredevops_git_repository.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/git_repository) | data source |
| [azuredevops_project.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
