provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "linux-functionapp"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-lfa"
}

module "functionapp" {
  source = "../../"

  name     = "${local.resource_prefix}-fa"
  location = local.location
  tags     = local.tags
}
