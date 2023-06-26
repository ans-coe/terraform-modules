provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "application-gateway"
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "agw-bas-demo-uks-03"
}

resource "azurerm_resource_group" "agw" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "agw" {
  name                = "vnet-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.agw.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "agw" {
  name                 = "snet-agw-default"
  resource_group_name  = azurerm_resource_group.agw.name
  virtual_network_name = azurerm_virtual_network.agw.name

  address_prefixes = ["10.0.0.0/27"]
}

module "agw" {
  source = "../../"

  name                = "agw-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.agw.name
  tags                = local.tags

  subnet_id = azurerm_subnet.agw.id

  basic_backends = {
    # curl -Lkv --resolve '*':80:${AGW_IP} http://example-basic-backend/
    # curl -Lkv --resolve '*':443:${AGW_IP} https://example-basic-backend/
    "example-basic-backend" = {
      hostname = "example-basic-backend"
    }
  }

  redirect_backends = {
    # curl -Lkv --resolve '*':80:${AGW_IP} http://example-redirect-backend/
    # curl -Lkv --resolve '*':443:${AGW_IP} https://example-redirect-backend/
    "example-redirect-backend" = {
      hostname = "example-redirect-backend"
      url      = "https://www.google.com"
    }
  }
}
