module "nsg" {
  source              = "../../modules/nsg"
  name                = "az-lbs-avd_ext-p-nsg-avd001"
  resource_group_name = module.rg[0].resource_group_name
  location            = var.location
  ### This will be created out of the box by Azure ###
  security_rules = [
    # {
    #   name                       = "AllowVnetInBound",
    #   priority                   = "65000"
    #   direction                  = "Inbound"
    #   access                     = "Allow"
    #   protocol                   = "*"
    #   source_port_range          = "*"
    #   destination_port_range     = "*"
    #   source_address_prefix      = "VirtualNetwork"
    #   destination_address_prefix = "VirtualNetwork"
    # },
    # {
    #   name                       = "AllowAzureLoadBalancerInBound",
    #   priority                   = "65001"
    #   direction                  = "Inbound"
    #   access                     = "Allow"
    #   protocol                   = "*"
    #   source_port_range          = "*"
    #   destination_port_range     = "*"
    #   source_address_prefix      = "AzureLoadBalancer"
    #   destination_address_prefix = "*"
    # },
    # {
    #   name                       = "DenyAllInBound",
    #   priority                   = "65500"
    #   direction                  = "Inbound"
    #   access                     = "Deny"
    #   protocol                   = "*"
    #   source_port_range          = "*"
    #   destination_port_range     = "*"
    #   source_address_prefix      = "*"
    #   destination_address_prefix = "*"
    # },
    # {
    #   name                       = "AllowVnetOutBound",
    #   priority                   = "65000"
    #   direction                  = "Outbound"
    #   access                     = "Allow"
    #   protocol                   = "*"
    #   source_port_range          = "*"
    #   destination_port_range     = "*"
    #   source_address_prefix      = "VirtualNetwork"
    #   destination_address_prefix = "VirtualNetwork"
    # },
    # {
    #   name                       = "AllowInternetOutBound",
    #   priority                   = "65001"
    #   direction                  = "Outbound"
    #   access                     = "Allow"
    #   protocol                   = "*"
    #   source_port_range          = "*"
    #   destination_port_range     = "*"
    #   source_address_prefix      = "*"
    #   destination_address_prefix = "Internet"
    # },
    # {
    #   name                       = "DenyAllOutBound",
    #   priority                   = "65500"
    #   direction                  = "Outbound"
    #   access                     = "Deny"
    #   protocol                   = "*"
    #   source_port_range          = "*"
    #   destination_port_range     = "*"
    #   source_address_prefix      = "*"
    #   destination_address_prefix = "*"
    # }
  ]

  ## tags ##
  application         = "nsg"
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

module "nsg-association-vdpool001" {
  source                    = "../../modules/nsg-association"
  subnet_id                 = module.subnet-vdpool001.subnet_id
  network_security_group_id = module.nsg.nsg_id
}

module "nsg-association-vdpool002" {
  source                    = "../../modules/nsg-association"
  subnet_id                 = module.subnet-vdpool002.subnet_id
  network_security_group_id = module.nsg.nsg_id
}

module "nsg-association-it001" {
  source                    = "../../modules/nsg-association"
  subnet_id                 = module.subnet-it001.subnet_id
  network_security_group_id = module.nsg.nsg_id
}

module "nsg-association-st001" {
  source                    = "../../modules/nsg-association"
  subnet_id                 = module.subnet-st001.subnet_id
  network_security_group_id = module.nsg.nsg_id
}