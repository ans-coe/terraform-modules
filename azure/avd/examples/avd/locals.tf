locals {
  default_tags = {
    environment         = "Production"
    workload_name       = "Azure Virtual Desktop"
    criticality         = "Tier 2"
    owner               = ""
    charge_code         = "VDI"
    data_classification = "Internal"
    lbsPatchDefinitions = "TBC"
    service_tier        = 2
    support_contact     = ""
    application         = "Virtual desktop infrastructure"
  }

  timezone = "GMT Standard Time"

  # Entra ID
  avd_group_display_name = "AVD Users"
  avd_user_01_object_id  = "axxxxxxx-axxx-axxx-axxx-axxxxxxxxxxx"
  avd_user_02_object_id  = "bxxxxxxx-bxxx-bxxx-bxxx-bxxxxxxxxxxx"

}
