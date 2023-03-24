provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "linux-webapp"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-lwa"
}

module "webapp" {
  source = "../../"

  name     = "${local.resource_prefix}-wa"
  location = local.location
  tags     = local.tags

  app_slot_names = ["preview"]
}
