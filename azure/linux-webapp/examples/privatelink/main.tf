provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "linux-webapp"
    example = "privatelink"
    usage   = "demo"
  }
  resource_prefix = "tfmex-pl-lwa"
}

resource "azurerm_resource_group" "webapp" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "webapp" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "webapp" {
  name                 = "privatelinks"
  resource_group_name  = azurerm_resource_group.webapp.name
  virtual_network_name = azurerm_virtual_network.webapp.name

  address_prefixes = ["10.0.0.0/25"]
}

resource "azurerm_private_dns_zone" "webapp" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "webapp" {
  name                  = format("%s_to_%s", azurerm_private_dns_zone.webapp.name, azurerm_virtual_network.webapp.name)
  resource_group_name   = azurerm_resource_group.webapp.name
  private_dns_zone_name = azurerm_private_dns_zone.webapp.name
  virtual_network_id    = azurerm_virtual_network.webapp.id
}

module "webapp" {
  source = "../../"

  name                = "${local.resource_prefix}-wa"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  plan = { name = "${local.resource_prefix}-sp" }

  application_stack = {
    docker_image     = "mcr.microsoft.com/appsvc/staticsite"
    docker_image_tag = "latest"
  }

  app_settings = {
    DOCKER_ENABLE_CI           = true
    DOCKER_REGISTRY_SERVER_URL = "https://mcr.microsoft.com"
  }
}

resource "azurerm_private_endpoint" "webapp" {
  name                = "${module.webapp.name}-pe"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  subnet_id = azurerm_subnet.webapp.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.webapp.id]
  }

  private_service_connection {
    name                           = "${module.webapp.name}-pe"
    private_connection_resource_id = module.webapp.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
