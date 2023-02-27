# Terraform Module - Azure DevOps - Project

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module is used to deploy an Azure DevOps project with repositories already created, including a repository specifically for the Wiki feature of the platform. It also contains some policies that can be optionally used, and exports the project ID if the requirements are more complex, for example if you were to add policies for branches other than the chosen default.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | ~> 0.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the project. | `string` | n/a | yes |
| <a name="input_author_email_policy"></a> [author\_email\_policy](#input\_author\_email\_policy) | Settings for the author email policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    email_patterns   = optional(list(string), ["*"])<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_case_enforcement_policy"></a> [case\_enforcement\_policy](#input\_case\_enforcement\_policy) | Settings for the case enforcement policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_comment_policy"></a> [comment\_policy](#input\_comment\_policy) | Settings for the comment resolution policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Name of the default branch. | `string` | `"main"` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the project. | `string` | `null` | no |
| <a name="input_enable_artifacts"></a> [enable\_artifacts](#input\_enable\_artifacts) | Enable artifacts. | `bool` | `true` | no |
| <a name="input_enable_boards"></a> [enable\_boards](#input\_enable\_boards) | Enable boards. | `bool` | `true` | no |
| <a name="input_enable_pipelines"></a> [enable\_pipelines](#input\_enable\_pipelines) | Enable pipelines. | `bool` | `true` | no |
| <a name="input_enable_testplans"></a> [enable\_testplans](#input\_enable\_testplans) | Enable testplans. | `bool` | `true` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | List of objects to configure each environment. | <pre>list(object({<br>    name        = string<br>    description = optional(string, "")<br>  }))</pre> | `[]` | no |
| <a name="input_file_path_policy"></a> [file\_path\_policy](#input\_file\_path\_policy) | Settings for the file path policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    denied_paths     = optional(list(string), ["badpath"])<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_file_size_policy"></a> [file\_size\_policy](#input\_file\_size\_policy) | Settings for the file size policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    max_file_size    = optional(number, 200)<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_path_length_policy"></a> [path\_length\_policy](#input\_path\_length\_policy) | Settings for the path length policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    max_path_length  = optional(number, 500)<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_repository_initialization_type"></a> [repository\_initialization\_type](#input\_repository\_initialization\_type) | Type of initialization to use when creating repositories. | `string` | `"Uninitialized"` | no |
| <a name="input_repository_names"></a> [repository\_names](#input\_repository\_names) | Set of names to use to create new repositories under the new project. | `set(string)` | `[]` | no |
| <a name="input_reserved_names_policy"></a> [reserved\_names\_policy](#input\_reserved\_names\_policy) | Settings for the reserved names policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_review_policy"></a> [review\_policy](#input\_review\_policy) | Settings for the review policy on the default branch. | <pre>object({<br>    enabled                        = bool<br>    blocking                       = optional(bool, true)<br>    reviewer_count                 = optional(number, 2)<br>    submitter_can_vote             = optional(bool, false)<br>    last_pusher_cannot_approve     = optional(bool, false)<br>    complete_with_rejects_or_waits = optional(bool, false)<br>    reset_votes_on_push            = optional(bool, false)<br>    require_vote_on_last_iteration = optional(bool, false)<br>    repository_names               = optional(list(string), [])<br>    repository_ids                 = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_teams"></a> [teams](#input\_teams) | List of objects to configure each team. At least one administrator and member descriptor must be provided. | <pre>list(object({<br>    name           = string<br>    description    = string<br>    administrators = optional(list(string))<br>    members        = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_teams_membership_mode"></a> [teams\_membership\_mode](#input\_teams\_membership\_mode) | Method used to manage memberships of teams. Add to append, Overwrite to overwrite the list. Overriden by team membership\_mode setting. | `string` | `"add"` | no |
| <a name="input_version_control"></a> [version\_control](#input\_version\_control) | The version control system to use in this project, 'Git' or 'Tfvc'. | `string` | `"Git"` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | The visibility of the project, 'private' or 'public'. | `string` | `"private"` | no |
| <a name="input_work_item_policy"></a> [work\_item\_policy](#input\_work\_item\_policy) | Settings for the work item policy. | <pre>object({<br>    enabled          = bool<br>    blocking         = optional(bool, true)<br>    repository_names = optional(list(string), [])<br>    repository_ids   = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_work_item_template"></a> [work\_item\_template](#input\_work\_item\_template) | The work item template to use. | `string` | `"Agile"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the created project. |
| <a name="output_name"></a> [name](#output\_name) | Name of the created project. |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | Output of project repositories. |

## Resources

| Name | Type |
|------|------|
| [azuredevops_branch_policy_comment_resolution.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_comment_resolution) | resource |
| [azuredevops_branch_policy_min_reviewers.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_min_reviewers) | resource |
| [azuredevops_branch_policy_work_item_linking.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_work_item_linking) | resource |
| [azuredevops_environment.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/environment) | resource |
| [azuredevops_git_repository.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository) | resource |
| [azuredevops_project.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/project) | resource |
| [azuredevops_repository_policy_author_email_pattern.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/repository_policy_author_email_pattern) | resource |
| [azuredevops_repository_policy_case_enforcement.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/repository_policy_case_enforcement) | resource |
| [azuredevops_repository_policy_file_path_pattern.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/repository_policy_file_path_pattern) | resource |
| [azuredevops_repository_policy_max_file_size.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/repository_policy_max_file_size) | resource |
| [azuredevops_repository_policy_max_path_length.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/repository_policy_max_path_length) | resource |
| [azuredevops_repository_policy_reserved_names.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/repository_policy_reserved_names) | resource |
| [azuredevops_team.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/team) | resource |
| [azuredevops_team_administrators.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/team_administrators) | resource |
| [azuredevops_team_members.main](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/team_members) | resource |
| [azuredevops_git_repositories.all](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/git_repositories) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
