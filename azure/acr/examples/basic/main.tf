provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "acr"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-acr"
}

module "acr" {
  source = "../../"

  name     = lower(replace("${local.resource_prefix}acr", "/[-_]/", ""))
  location = local.location
  tags     = local.tags
}
