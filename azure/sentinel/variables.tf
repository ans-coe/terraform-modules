###################
# Global Variables
###################

variable "location" {
  description = "The region in which resources will be created"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

variable "tenant_id" {
  description = "The tenant ID"
  type        = string
  default     = null
}

##########################
# Log Analytics Workspace
##########################

variable "log_analytics_workspace_id" {
  description = "The id of an existing Log Anylitics Workspace"
  type        = string
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "Name of the new Log Anylitics Workspace to be created"
  type        = string
  default     = null
}

variable "log_analytics_workspace_retention" {
  description = "Retention in days."
  type        = number
  default     = 90
}

variable "log_analytics_workspace_sku" {
  description = "The SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

#################
# Azure Sentinel
#################

variable "customer_managed_key_enabled" {
  description = "pecifies if the Workspace is using Customer managed key. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

##################
# Data Connectors
##################

variable "dc_ad_enabled" {
  description = "Enable the Data Connector: Azure Active Directory"
  type        = bool
  default     = false
}

variable "dc_security_center_enabled" {
  description = "Enable the Data Connector: Azure Security Centre"
  type        = bool
  default     = false
}

variable "dc_advanced_threat_protection_enabled" {
  description = "Enable the Data Connector: Azure Active Directory Identity Protection"
  type        = bool
  default     = false
}

variable "dc_microsoft_cloud_app_security_enabled" {
  description = "Enable the Data Connector: Microsoft 365 Defender"
  type        = bool
  default     = false
}

variable "dc_office_365_enabled" {
  description = "Enable the Data Connector: Office 365"
  type        = bool
  default     = false
}

variable "dc_microsoft_threat_intelligence_enabled" {
  description = "Enable the Data Connector: Threat Intelligence"
  type        = bool
  default     = false
}

variable "dc_microsoft_defender_advanced_threat_protection_enabled" {
  description = "Enable the Data Connector: Microsoft Defender Advanced Threat Protection"
  type        = bool
  default     = false
}

variable "dc_microsoft_threat_protection_enabled" {
  description = "Enable the Data Connector: Microsoft Threat Protection"
  type        = bool
  default     = false
}

variable "cloud_app_security_config" {
  description = "Configuration for the Microsoft 365 Defender Data Connector"
  type = object({
    alerts_enabled         = optional(bool, true)
    discovery_logs_enabled = optional(bool, true)
  })
  default = {
    alerts_enabled         = true
    discovery_logs_enabled = true
  }
}

variable "office_365_config" {
  description = "Configuration for the Office 365 Data Connector"
  type = object({
    exchange_enabled   = optional(bool, true)
    sharepoint_enabled = optional(bool, true)
    teams_enabled      = optional(bool, true)
  })
  default = {
    exchange_enabled   = true
    sharepoint_enabled = true
    teams_enabled      = true
  }
}

variable "microsoft_threat_intelligence_feed_lookback_date" {
  description = "The lookback date for the Microsoft Emerging Threat Feed in RFC3339. Changing this forces a new Data Connector to be created."
  type        = string
  default     = "1970-01-01T00:00:00Z"
}