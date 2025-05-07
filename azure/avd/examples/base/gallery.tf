module "image-gallery" {
  source                           = "../../modules/computer-gallery"
  shared_image_gallery_name        = "az_lbs_avd_ext_p_gal001"
  location                         = var.location
  resource_group_name              = module.rg[2].resource_group_name #az-lbs-avd_ext-gal-p-rg
  shared_image_gallery_description = "The Azure Compute Gallery to store images created by for the External Parties Azure Virtual Desktop environment."

  shared_images_definitions = [
    {
      name = "az-lbs-avd_ext-p-def001"
      identifier = {
        offer                               = "Windows-11"
        publisher                           = "MicrosoftWindowsDesktop"
        sku                                 = "ExternalParties"
        accelerated_network_support_enabled = true
        trusted_launch_enabled              = true
      }
      os_type                             = "Windows"
      description                         = "External Parties Image Definition Basics."
      trusted_launch_enabled              = true
      accelerated_network_support_enabled = true
    }
  ]

  ## tags ##
  application         = "gal"
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
}
