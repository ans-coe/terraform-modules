variable "tags" {
  description = "Tags for the resource"
  type        = map(string)
  default     = null
}

variable "key_name" {
  description = "Name of the KMS Key"
  type        = string
}

variable "dest_account_ids" {
  description = "A list of remote accounts that the key will be shared to"
  type        = list(string)
  default     = []
}

variable "dest_iam_roles" {
  description = "A list of remote IAM roles that have access to the key"
  type        = list(string)
  default     = []
}

variable "src_account_id" {
  description = "Account that the key will be created in"
  type        = string
}

variable "src_iam_roles" {
  description = "A list of local IAM roles that have access to the key"
  type        = list(string)
}


