provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
  tags     = var.tags
}

module "example" {
  source = "../../"

  name                = "${var.resource_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  address_space = ["10.0.0.0/16"]
  subnets = [
    {
      name   = "default"
      prefix = "10.0.0.0/24"
    }
  ]
}
