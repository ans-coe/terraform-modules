module "storage-appattach" {

  source              = "../../modules/storage-account"
  name                = ""
  location            = var.location
  resource_group_name = module.rg[1].resource_group_name
  ## tags ##
  application         = "st"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}

  file_shares = [
    {
      name        = ""
      quota_in_gb = 100
      # acl = [ 
      #   {
      #     id = ""
      #     permissions = ""
      #   }
      #  ]
    }
  ]

  depends_on = [module.rg]
}


#### PEP created outside of Terraform due to permissions ######


# module "storage-appattach-pep" {
#   source = "../../modules/pep"

#   private_endpoint_name           = "az-lbs-avd_ext-p-snet-peps-appattach001"
#   resource_group_name             = module.rg[1].resource_group_name 
#   location                        = var.location
#   subnet_id                       = module.subnet-st001.subnet_id 
#   private_dns_zone_group_name     = "privatelink.file.core.windows.net" 
#   private_service_connection_name = "appattach001-privateserviceconnection"
#   # private_dns_zones_ids           = [
#   #   ]
#   subresource_name                = ["File"]
#   target_resource                 = module.storage-appattach.storage_account_id


#   ## tags ##
#   application         = "st"
#   workload_name       = local.default_tags.workload_name
#   owner               = local.default_tags.owner
#   service_tier        = local.default_tags.service_tier
#   data_classification = local.default_tags.data_classification
#   support_contact     = local.default_tags.support_contact
#   environment         = local.default_tags.environment
#   charge_code         = local.default_tags.charge_code
#   criticality         = local.default_tags.criticality
#   lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

#   extra_tags = {}
# }
