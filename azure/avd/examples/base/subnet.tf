module "subnet-vdpool001" {
  source               = "../../modules/subnet"
  name                 = ""
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.8.58.0/25"]
  resource_group_name  = module.rg[0].resource_group_name

  depends_on = [module.vnet, module.rg]
}

module "subnet-vdpool002" {
  source               = "../../modules/subnet"
  name                 = ""
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.8.59.0/29"]
  resource_group_name  = module.rg[0].resource_group_name

  depends_on = [module.vnet, module.rg]
}

module "subnet-it001" {
  source               = "../../modules/subnet"
  name                 = ""
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.8.59.8/29"]
  resource_group_name  = module.rg[0].resource_group_name

  depends_on = [module.vnet, module.rg]
}

module "subnet-st001" {
  source               = "../../modules/subnet"
  name                 = ""
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.8.59.16/29"]
  resource_group_name  = module.rg[0].resource_group_name

  depends_on = [module.vnet, module.rg]
}