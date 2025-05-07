module "vnet" {
  source                        = "../../modules/vnet"
  name                          = ""
  resource_group_name           = module.rg[0].resource_group_name
  location                      = var.location
  virtual_network_dns_servers   = ["10.8.254.132"]
  virtual_network_address_space = ["10.8.58.0/23"]

  ## tags ##
  application         = "vnet"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions
}