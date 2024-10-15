variable "default_tags" {
  description = "Default Base tagging"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "workload_name" {
  description = "Project workload name"
  type        = string
}

variable "criticality" {
  description = "Project criticality"
  type        = string
}

variable "owner" {
  description = "Project Owner"
  type        = string
}

variable "charge_code" {
  description = "Project charge code"
  type        = string
}

variable "data_classification" {
  description = "Data Classification"
  type        = string
}

variable "lbsPatchDefinitions" {
  description = "LBS Patch Definitions"
  type        = string
}

variable "service_tier" {
  description = "Project service tier"
  type        = number
}

variable "support_contact" {
  description = "Support Contact"
  type        = string
}

variable "application" {
  description = "Application type, values can be App Attach, External Parties, Microsoft Edge. ETC"
  type        = string
}

# variable "default_tags_enabled" {
#   description = "Option to enable or disable default tags."
#   type        = bool
#   default     = true
# }

variable "extra_tags" {
  description = "Additional tags to associate with your Azure Storage Account."
  type        = map(string)
  default     = {}
}