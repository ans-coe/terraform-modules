provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  tags = {
    module  = "naming"
    example = "advanced"
    usage   = "demo"
  }
}

module "naming" {
  source = "../../"

  workload = "hub"
  environment = "prod"
  region = "uksouth"

  convention = ["T", "W", "E", "R", "I"]
  delimiter = "-"

  resource_override = {
    api_management = {
      dashes = true
    }
  }
}

resource "azurerm_resource_group" "example" {
  name = module.naming.az.resource_group[0].name
  location = "uksouth"
  tags = local.tags
}

resource "azurerm_api_management" "example" {
  name = module.naming.az.api_management[0].name
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
  publisher_name = "dwdijadpajwd"
  publisher_email = "asdads@asdasd.com"
  sku_name = "Standard_1"

  
}



