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

  name                = "${var.resource_prefix}-as"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  plan = {
    name = "${var.resource_prefix}-sp"
  }

  application_stack = {
    docker_image     = "mcr.microsoft.com/appsvc/staticsite"
    docker_image_tag = "latest"
  }

  app_settings = {
    DOCKER_ENABLE_CI           = true
    DOCKER_REGISTRY_SERVER_URL = "https://mcr.microsoft.com"
  }
}
