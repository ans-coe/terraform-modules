#########
# Global
#########

variable "location" {
  description = "The location of created resources."
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
  default     = "terraform-ops-rg"
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

###########
# Security
###########

variable "managed_tenant_id" {
  description = "The tenant id that will be used for management."
  type        = string
  default     = null
}

variable "application_name" {
  description = "Name of the application created for Terraform."
  type        = string
  default     = "Terraform"
}

variable "msgraph_roles" {
  description = "Assignable MS Graph roles to allow MS Graph / AAD access."
  type        = list(string)
  default = [
    "Application.Read.All",
    "Group.Read.All",
    "User.Read.All"
  ]
}

variable "role" {
  description = "The role that the application will be given for ARM access."
  type        = string
  default     = "Owner"
}

variable "managed_scopes" {
  description = "Scopes to be managed by Terraform."
  type        = set(string)
  default     = []
}

variable "group_name" {
  description = "Name used to create the Terraform Operators group."
  type        = string
  default     = "Terraform Operators"
}

variable "group_description" {
  description = "Description used to create the Terraform Operators group."
  type        = string
  default     = "A group for Terraform Operators with access to Terraform resources used for state and secrets."
}

variable "terraform_group_member_ids" {
  description = "Object IDs for administrative objects with full access to the Key Vault and Storage Account."
  type        = set(string)
  default     = []
}

variable "storage_account_name" {
  description = "Name of the storage account."
  type        = string
}

variable "key_vault_name" {
  description = "Name of the key vault."
  type        = string
}

variable "enable_key_vault_rbac" {
  description = "Enable RBAC over access policies with the key vault."
  type        = bool
  default     = false
}

variable "enable_purge_protection" {
  description = "Enable purge protection on the key vault."
  type        = bool
  default     = false
}

variable "enable_shared_access_key" {
  description = "Enable shared access key on storage account."
  type        = bool
  default     = true
}

variable "allowed_ips" {
  description = "IPs or CIDRs allowed to connect to the created Key Vault and Storage Account."
  type        = list(string)
  default     = null
}

variable "allowed_subnet_ids" {
  description = "Subnet IDs allowed to connect to the created Key Vault and Storage Account."
  type        = list(string)
  default     = null
}
