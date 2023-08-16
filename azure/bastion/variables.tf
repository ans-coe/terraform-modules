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
  default     = null
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

########################
# Bastion Configuration
########################

variable "name" {
  description = "The name of the Bastion."
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP for this Bastion."
  type        = string
  default     = null
}

variable "network_security_group_name" {
  description = "The name of the Network Security Group for this Bastion."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet to create this Bastion in."
  type        = string
}

variable "whitelist" {
  description = "A list of allowed CIDR ranges or service tags to give access to the bastion. Default to Internet service tag."
  type        = list(string)
  default     = ["Internet"]
}

variable "sku" {
  description = "The SKU of the Bastion."
  type        = string
  default     = "Basic"
}

variable "scale_units" {
  description = "Number of scale units in this Bastion."
  type        = number
  default     = 2
}
