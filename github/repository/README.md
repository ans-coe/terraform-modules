# Terraform Module - Github - Repository

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This Terraform configuration will create a Github repository and allow for a degree of management with collaborators and teams, deploy keys and webhooks. It will also output details of the repository if there is a preference to add your own resources over the ones that the module provides to configure elements like Webhooks, or if you want to add Projects to the configuration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the repository. | `string` | n/a | yes |
| <a name="input_archive_on_destroy"></a> [archive\_on\_destroy](#input\_archive\_on\_destroy) | If true, archive repository instead of destroying it with Terraform. | `bool` | `false` | no |
| <a name="input_auto_init"></a> [auto\_init](#input\_auto\_init) | If true, produce an initial commit on repository creation. | `bool` | `true` | no |
| <a name="input_collaborators"></a> [collaborators](#input\_collaborators) | List of objects containing collaborators and their permissions. Valid permissions are pull, push, triage, maintain and admin. | <pre>list(<br>    object({<br>      username         = string<br>      permission       = optional(string)<br>      diff_suppression = optional(bool)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Default branch of the repository. | `string` | `"main"` | no |
| <a name="input_deploy_keys"></a> [deploy\_keys](#input\_deploy\_keys) | List of objects containing deploy keys and their read\_only status. | <pre>list(<br>    object({<br>      name       = string<br>      public_key = string<br>      read_only  = optional(bool, true)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the repository. | `string` | `null` | no |
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | Template for .gitignore. Use the name without the extension from here: https://github.com/github/gitignore | `string` | `null` | no |
| <a name="input_has_discussions"></a> [has\_discussions](#input\_has\_discussions) | Has Discussions feature activated. | `bool` | `false` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | Has Issues feature activated. | `bool` | `false` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | Has Projects feature activated. | `bool` | `false` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | Has Wiki feature activated. | `bool` | `false` | no |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | Homeage URL of the repository. | `string` | `null` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | Set to true if this repository is used as a template. | `bool` | `false` | no |
| <a name="input_issue_labels"></a> [issue\_labels](#input\_issue\_labels) | List of objects containing issue labels. Color is in hex format without leading #. | <pre>list(<br>    object({<br>      name        = string<br>      color       = optional(string, "00FF00")<br>      description = optional(string)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_license_template"></a> [license\_template](#input\_license\_template) | Template for the repository license. Use the name without the extension from here: https://github.com/github/choosealicense.com/tree/gh-pages/_licenses | `string` | `null` | no |
| <a name="input_pages_branch"></a> [pages\_branch](#input\_pages\_branch) | Branch to use for Github Pages site. | `string` | `null` | no |
| <a name="input_pages_cname"></a> [pages\_cname](#input\_pages\_cname) | Custom domain to use for Github Pages site. (Only works after repository has been created) | `string` | `null` | no |
| <a name="input_pages_path"></a> [pages\_path](#input\_pages\_path) | Path to use for Github Pages site. | `string` | `"/"` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | List of objects containing projects. | <pre>list(<br>    object({<br>      name = string<br>      body = optional(string)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | List of objects containing teams and their permissions. Valid permissions are pull, push, triage, maintain and admin. | <pre>list(<br>    object({<br>      team_id    = string<br>      permission = optional(string)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_template"></a> [template](#input\_template) | The repository to use as a template in owner/repository format. | `string` | `null` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Topics to add to the repository. | `list(string)` | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Controls the visibility of the repository. | `string` | `"private"` | no |
| <a name="input_vunlerability_alerts"></a> [vunlerability\_alerts](#input\_vunlerability\_alerts) | Has Vulnerability Alerts feature activated. | `bool` | `null` | no |
| <a name="input_webhooks"></a> [webhooks](#input\_webhooks) | List of objects containing webhooks and their configuration. See github\_repository\_webhook documentation for more. | <pre>list(<br>    object({<br>      url          = string<br>      active       = optional(bool, true)<br>      events       = list(string)<br>      content_type = optional(string, "json")<br>      insecure_ssl = optional(bool, false)<br>      secret       = optional(string)<br>    })<br>  )</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_clone_url_http"></a> [clone\_url\_http](#output\_clone\_url\_http) | URL to clone the repository using HTTPS. |
| <a name="output_clone_url_ssh"></a> [clone\_url\_ssh](#output\_clone\_url\_ssh) | URL to clone the repository using SSH. |
| <a name="output_default_branch"></a> [default\_branch](#output\_default\_branch) | Default branch of the repository. |
| <a name="output_name"></a> [name](#output\_name) | Name of the repository. |
| <a name="output_web_url"></a> [web\_url](#output\_web\_url) | URL of the repository. |

## Resources

| Name | Type |
|------|------|
| [github_branch_default.main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_issue_label.main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/issue_label) | resource |
| [github_repository.main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_collaborator.main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborator) | resource |
| [github_repository_deploy_key.main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key) | resource |
| [github_repository_project.project](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_project) | resource |
| [github_repository_webhook.main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [github_team_repository.main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |