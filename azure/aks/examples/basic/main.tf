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

  name                = "${var.resource_prefix}-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  node_count = 2
}
