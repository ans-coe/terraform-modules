variable "shared_image_gallery_name" {
  description = "Specifies the name of the Shared Image Gallery."
  type        = string
}

variable "shared_image_gallery_description" {
  description = "A description for this Shared Image Gallery."
  type        = string
  default     = null
}

variable "community_gallery" {
  description = "Configure the Shared Image Gallery as a Community Gallery."
  type = object({
    eula            = string
    prefix          = string
    publisher_email = string
    publisher_uri   = string
  })
  default = null
}

variable "shared_images_definitions" {
  description = "Create Shared Image Definition."
  type = list(object({
    name = string
    identifier = object({
      offer     = string
      publisher = string
      sku       = string
    })
    os_type                             = string
    description                         = optional(string)
    disk_types_not_allowed              = optional(list(string))
    end_of_life_date                    = optional(string)
    eula                                = optional(string)
    specialized                         = optional(bool)
    architecture                        = optional(string, "x64")
    hyper_v_generation                  = optional(string, "V2")
    max_recommended_vcpu_count          = optional(number)
    min_recommended_vcpu_count          = optional(number)
    max_recommended_memory_in_gb        = optional(number)
    min_recommended_memory_in_gb        = optional(number)
    privacy_statement_uri               = optional(string)
    release_note_uri                    = optional(string)
    trusted_launch_enabled              = optional(bool)
    confidential_vm_supported           = optional(bool)
    confidential_vm_enabled             = optional(bool)
    accelerated_network_support_enabled = optional(bool)
    tags                                = optional(map(string))
  }))
  default = []
}
