provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module     = "route-table"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic-rt"
}

resource "azurerm_resource_group" "main" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-prod = {
      prefix = "10.0.0.0/24"
    }
  }
}

module "route-table" {
  source = "../.."

  name                = "${local.resource_prefix}-rt"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  subnet_ids = [module.network.subnets["snet-prod"].id]

  default_route_ip = "1.2.3.4"
}