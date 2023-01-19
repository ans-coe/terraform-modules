provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.resource_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "example_privatelinks" {
  name                 = "privatelinks"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes                              = ["10.0.0.0/25"]
  enforce_private_link_service_network_policies = true
}

resource "azurerm_private_dns_zone" "example_app" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "app" {
  name                  = format("%s_to_%s", azurerm_private_dns_zone.example_app.name, azurerm_virtual_network.example.name)
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example_app.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

module "example" {
  source = "../../"

  name                = "${var.resource_prefix}-wa"
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

resource "azurerm_private_endpoint" "example" {
  name                = "${module.example.name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  subnet_id = azurerm_subnet.example_privatelinks.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.example_app.id]
  }

  private_service_connection {
    name                           = "${module.example.name}-pe"
    private_connection_resource_id = module.example.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
