provider "azurerm" {
  features {}
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

resource "azurerm_resource_group" "nsg" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}