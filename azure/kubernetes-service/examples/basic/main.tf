provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "aks"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-aks"
}

module "aks" {
  source = "../../"

  name     = "${local.resource_prefix}-aks"
  location = local.location
  tags     = local.tags

  node_count = 2
}
