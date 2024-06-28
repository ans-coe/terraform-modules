provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module  = "app-service-webapp"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-aswa"
}

resource "azurerm_resource_group" "webapp" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

module "webapp" {
  source = "../../"

  os_type = "Windows"

  name                = "${local.resource_prefix}-wa"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  plan = {
    # Required as Basic/Windows only supports single-slot.
    sku_name = "S1"
  }

  slots = ["preview"]
}
