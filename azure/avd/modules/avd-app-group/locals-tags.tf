locals {
  default_tags = {
    environment         = var.environment
    workload_name       = var.workload_name
    criticality         = var.criticality
    owner               = var.owner
    charge_code         = var.charge_code
    data_classification = var.data_classification
    lbsPatchDefinitions = var.lbsPatchDefinitions
    service_tier        = var.service_tier
    support_contact     = var.support_contact
    application         = var.application
  }
}
