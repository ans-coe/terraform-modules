# Terraform (Module) - AWS - CodeDeploy Workflow - Build

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

The build portion of the CodeDeploy Workflow module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.19 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_branches"></a> [branches](#input\_branches) | List of branch names to create pipelines for | `list(string)` | n/a | yes |
| <a name="input_code_commit_repo"></a> [code\_commit\_repo](#input\_code\_commit\_repo) | Name of the Code Commit Repo | `string` | n/a | yes |
| <a name="input_deployment_roles"></a> [deployment\_roles](#input\_deployment\_roles) | List of ARNs of roles that will be used in the deployment steps. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Application | `string` | n/a | yes |
| <a name="input_create_code_commit_repo"></a> [create\_code\_commit\_repo](#input\_create\_code\_commit\_repo) | Create a code commit repo | `bool` | `false` | no |
| <a name="input_enable_codepipeline"></a> [enable\_codepipeline](#input\_enable\_codepipeline) | Whether to include the CodePipeline | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Providing a KMS Key will stop one from being generated | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the deployment bucket |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The ARN of the KMS Key |

## Resources

| Name | Type |
|------|------|
| [aws_codecommit_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) | resource |
| [aws_codepipeline.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket_policy.deploy_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_arn.deployment_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_codecommit_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/codecommit_repository) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deploy_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_deploy_bucket"></a> [deploy\_bucket](#module\_deploy\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.15 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | ../../kms_key | n/a |
| <a name="module_pipeline_bucket"></a> [pipeline\_bucket](#module\_pipeline\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.15 |
<!-- END_TF_DOCS -->
