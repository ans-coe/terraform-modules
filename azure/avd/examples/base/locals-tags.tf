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
    support_contact     = "azureplatform@"
    application         = "Networking"
  }
}
