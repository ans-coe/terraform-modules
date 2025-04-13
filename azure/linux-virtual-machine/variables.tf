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
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

#########################
# Virtual Machine Config
#########################

variable "name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "computer_name" {
  description = "The OS-level computer name of the virtual machine."
  type        = string
  default     = null
}

variable "username" {
  description = "Username of the virtual machine."
  type        = string
  default     = "vmadmin"
}

variable "public_key" {
  description = "Public key of the virtual machine."
  type        = string
}

variable "user_data_b64" {
  description = "User data of the virtual machine with in base64."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID of the virtual machine."
  type        = string
}

variable "ip_forwarding" {
  description = "Enable IP forwarding on the virtual machine NIC."
  type        = bool
  default     = false
}

variable "ip_address" {
  description = "Private IP address of the virtual machine NIC."
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "The DNS servers to use with this virtual network."
  type        = list(string)
  default     = null
}

variable "public_ip_enabled" {
  description = "Enable public IP."
  type        = bool
  default     = false
}

variable "lb_backend_address_pool_ids" {
  description = "IDs of load balancer backends to assign this virtual machine's primary NIC to."
  type        = list(string)
  default     = []
}

variable "agw_backend_address_pool_ids" {
  description = "IDs of application gateways backends to assign this virtual machine's primary NIC to."
  type        = list(string)
  default     = []
}

variable "network_security_group_enabled" {
  description = "Assign a network security group."
  type        = bool
  default     = false
}

variable "network_security_group_id" {
  description = "ID of the network security group to use with the virtual machine NIC."
  type        = string
  default     = null
}

variable "size" {
  description = "Size of the virtual machine."
  type        = string
  default     = "Standard_B1s"
}

variable "patch_assessment_mode" {
  description = "The patch assessment mode of the virtual machine."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "Size of the OS Disk in GB."
  type        = number
  default     = 128
}

variable "os_disk_storage_account_type" {
  description = "Type of the storage account."
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.os_disk_storage_account_type)
    error_message = "The os_disk_storage_account_type must be 'Standard_LRS', 'StandardSSD_LRS', 'Premium_LRS', 'StandardSSD_ZRS' or 'Premium_ZRS'."
  }
}

variable "os_disk_caching" {
  description = "Caching option of the OS Disk."
  type        = string
  default     = "None"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "The os_disk_caching must be 'None', 'ReadOnly' or 'ReadWrite'."
  }
}

variable "availability_set_id" {
  description = "Availability set ID to add this virtual machine to."
  type        = string
  default     = null
}

variable "capacity_reservation_group_id" {
  description = "Capacity Reservation Group ID to add this virtual machine to."
  type        = string
  default     = null
}

variable "source_image_id" {
  description = "Source image ID to use when creating the virtual machine."
  type        = string
  default     = null
}

variable "license_type" {
  description = "License type to use when building the virtual machine."
  type        = string
  default     = null
}

variable "source_image_plan_required" {
  description = "Enable if plan block is required as part of the virtual machine."
  type        = bool
  default     = false
}

variable "accept_terms" {
  description = "Enable if terms are needed to be accepted"
  type        = bool
  default     = false
}

variable "source_image_reference" {
  description = "Source image reference to use when creating the virtual machine."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
  default = null
}

variable "identity_ids" {
  description = "User assigned identity IDs to append to this virtual machine."
  type        = list(string)
  default     = []
}

variable "enable_azure_monitor" {
  description = "Enable Azure Monitor extension."
  type        = bool
  default     = true
}

variable "enable_aad_login" {
  description = "Enable AAD Login extension."
  type        = bool
  default     = true
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy extension."
  type        = bool
  default     = true
}

variable "enable_network_watcher" {
  description = "Enable Network Watcher extension."
  type        = bool
  default     = true
}

variable "data_collection_enabled" {
  description = "Enable data collection association."
  type        = bool
  default     = false
}

variable "data_collection_rule_id" {
  description = "Data collection rule ID to associate to this virtual machine."
  type        = string
  default     = null
}

variable "autoshutdown" {
  description = "Describes the autoshutdown configuration with time being in 24h format and timezone being a supported timezone."
  type = object({
    time     = optional(string, "2200")
    timezone = optional(string, "UTC")
    email    = optional(string)
  })
  default = null
}
