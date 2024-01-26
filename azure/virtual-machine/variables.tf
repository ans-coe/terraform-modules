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

variable "os_type" {
  description = "The OS type to use."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "The OS type must be either Windows or Linux"
  }
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

variable "password" {
  description = "Password of the virtual machine."
  type        = string
  default     = null
  sensitive   = true
}

variable "public_key" {
  description = "Public key of the virtual machine."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data of the virtual machine."
  type        = string
  default     = null
}

variable "availability_set_id" {
  description = "Availability set ID to add this virtual machine to."
  type        = string
  default     = null
}

variable "size" {
  description = "Size of the virtual machine."
  type        = string
  default     = "Standard_B2s"
}

variable "boot_diagnostics_storage_account_uri" {
  description = "Storage account blob endpoint to use for boot diagnostics."
  type        = string
  default     = null
}

variable "network_interface_name" {
  description = "Name of the network interface."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID of the virtual machine."
  type        = string
}

variable "enable_ip_forwarding" {
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

variable "enable_public_ip" {
  description = "Enable public IP."
  type        = bool
  default     = false
}

variable "public_ip_name" {
  description = "Name of the public IP."
  type        = string
  default     = null
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method."
  type        = string
  default     = "Dynamic"
}

variable "public_ip_hostname" {
  description = "Public IP hostname."
  type        = string
  default     = null
}

variable "backend_address_pool_ids" {
  description = "IDs of load balancer backends to assign this virtual machine's primary NIC to."
  type        = set(string)
  default     = []
}

variable "enable_network_security_group" {
  description = "Assign a network security group."
  type        = bool
  default     = false
}

variable "network_security_group_id" {
  description = "ID of the network security group to use with the virtual machine NIC."
  type        = string
  default     = null
}

variable "license_type" {
  description = "License type of the virtual machine."
  type        = string
  default     = null
}

variable "patch_assessment_mode" {
  description = "Patch assessment mode of the virtual machine."
  type        = string
  default     = null
}

variable "patch_mode" {
  description = "Patch mode of the virtual machine."
  type        = string
  default     = null
}

variable "hotpatching_enabled" {
  description = "Should the VM be patched without requiring a reboot?  Hotpatching can only be enabled if the patch_mode is set to AutomaticByPlatform, the provision_vm_agent is set to true, your source_image_reference references a hotpatching enabled image, and the VM's size is set to a Azure generation 2 VM."
  type        = string
  default     = false
}

variable "os_disk" {
  description = "OS Disk configuration."
  type = object({
    name                 = optional(string)
    size_gb              = optional(number, 128)
    storage_account_type = optional(string, "StandardSSD_LRS")
    caching              = optional(string, "None")
  })
  default = {}
}

variable "disk_attachments" {
  description = "Disks to attach to this VM."
  type = map(object({
    id      = string
    lun     = number
    caching = optional(string, "None")
  }))
  default = {}
}

variable "source_image_id" {
  description = "Source image ID to use when creating the virtual machine."
  type        = string
  default     = null
}

variable "source_image_plan_required" {
  description = "Enable if plan block is required as part of the virtual machine."
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

variable "backup_config" {
  description = "Configuration of the backup."
  type = object({
    backup_policy_id  = string
    include_disk_luns = optional(set(number))
    exclude_disk_luns = optional(set(number))
  })
  default = null
}

variable "enable_network_watcher" {
  description = "Enable Network Watcher extension."
  type        = bool
  default     = false
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy extension."
  type        = bool
  default     = false
}

variable "enable_azure_monitor" {
  description = "Enable Azure Monitor extension."
  type        = bool
  default     = false
}

variable "enable_dependency_agent" {
  description = "Enable Azure Monitor Dependency Agent extension."
  type        = bool
  default     = false
}

variable "enable_data_collection" {
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
  description = "Describes the autoshutdown configuration of this virtual machine with time being 24h format and timezone being a supported timezone. Set to an empty map to enable."
  type = object({
    time     = optional(string, "2200")
    timezone = optional(string, "UTC")
    email    = optional(string)
  })
  default = null
}

variable "enable_encryption_at_host" {
  description = "Adds the option of adding enabling encryption at host"
  type        = bool
  default     = null
}
