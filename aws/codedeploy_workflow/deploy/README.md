# Terraform (Module) - AWS - CodeDeploy Workflow - Deploy

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

The deploy portion of the CodeDeploy Workflow module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.19 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_list"></a> [asg\_list](#input\_asg\_list) | List of ASGs to deploy code to | `list(string)` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Branch name of the deployment | `string` | n/a | yes |
| <a name="input_deployment_bucket_name"></a> [deployment\_bucket\_name](#input\_deployment\_bucket\_name) | Name of the bucket where the source object is | `string` | n/a | yes |
| <a name="input_key_arn"></a> [key\_arn](#input\_key\_arn) | The ARN of the KMS Key | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_asg_loadbalancer_target_name"></a> [asg\_loadbalancer\_target\_name](#input\_asg\_loadbalancer\_target\_name) | The Target group name for the loadbalancer. Required if deployment\_group.blue\_green is true | `string` | `null` | no |
| <a name="input_deployment_group"></a> [deployment\_group](#input\_deployment\_group) | Variables relating to the deployment group | <pre>object({<br>    auto_rollback          = optional(bool, true)<br>    with_traffic_control   = optional(bool, false)<br>    blue_green             = optional(bool, false)<br>    deployment_config_name = optional(string, "CodeDeployDefault.AllAtOnce")<br>  })</pre> | `{}` | no |
| <a name="input_enable_codepipeline"></a> [enable\_codepipeline](#input\_enable\_codepipeline) | Whether to include the CodePipeline | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch"></a> [branch](#output\_branch) | Branch Argument |
| <a name="output_deployment_bucket_id"></a> [deployment\_bucket\_id](#output\_deployment\_bucket\_id) | Bucket used for CodeDeploy |
| <a name="output_deployment_role"></a> [deployment\_role](#output\_deployment\_role) | Role used to deploy |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The ARN of the KMS Key |

## Resources

| Name | Type |
|------|------|
| [aws_codedeploy_app.deploy_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_group.deployment_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_codepipeline.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_role.codedeploy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.deployment_pipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.codebuild-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.AWSCodeDeployRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.code_pipeline_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pipeline_bucket"></a> [pipeline\_bucket](#module\_pipeline\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.15 |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |
