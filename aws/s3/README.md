# KMS Account Sharing Module

A module to create custom kms key and share access to multiple AWS accounts with option to add  particular IAM Roles and Users
## Sample way of using this module

Using policy to create kms key and share to dest accounts

```
module "kms_sharing" {
  source           = "./_module/kms"
  version          = "1.0.0"
  key_name         = "devops-key-sharing"
  dest_account_ids = ["1111111", "222222", "333333"]
  dest_iam_roles   = ["arn:aws:iam::xxxxxx:role/dest_iam_role"](optional)
  src_account_id  = "444444"
  src_iam_roles   = ["arn:aws:iam::xxxxxx:role/src_iam_role"](optional)
}
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.19 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of the KMS Key | `string` | n/a | yes |
| <a name="input_src_account_id"></a> [src\_account\_id](#input\_src\_account\_id) | Account that the key will be created in | `string` | n/a | yes |
| <a name="input_src_iam_roles"></a> [src\_iam\_roles](#input\_src\_iam\_roles) | A list of local IAM roles that have access to the key | `list(string)` | n/a | yes |
| <a name="input_dest_account_ids"></a> [dest\_account\_ids](#input\_dest\_account\_ids) | A list of remote accounts that the key will be shared to | `list(string)` | `[]` | no |
| <a name="input_dest_iam_roles"></a> [dest\_iam\_roles](#input\_dest\_iam\_roles) | A list of remote IAM roles that have access to the key | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the resource | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_alias_arn"></a> [key\_alias\_arn](#output\_key\_alias\_arn) | n/a |
| <a name="output_key_alias_id"></a> [key\_alias\_id](#output\_key\_alias\_id) | n/a |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | n/a |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | n/a |
| <a name="output_policy"></a> [policy](#output\_policy) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_iam_policy_document.key_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |