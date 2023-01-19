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

  name                = lower(replace("${var.resource_prefix}acr", "/[-_]/", ""))
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags
}
