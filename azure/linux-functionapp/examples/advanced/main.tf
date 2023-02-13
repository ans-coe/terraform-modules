provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "linux-functionapp"
    example = "advanced"
    usage   = "demo"
  }
  resource_prefix = "tfmex-adv-lfa"
}

resource "azurerm_resource_group" "functionapp" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_service_plan" "functionapp" {
  name                = "${local.resource_prefix}-sp"
  location            = local.location
  resource_group_name = azurerm_resource_group.functionapp.name
  tags                = local.tags

  sku_name = "S1"

  os_type = "Linux"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_virtual_network" "functionapp" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.functionapp.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "functionapp" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.functionapp.name
  virtual_network_name = azurerm_virtual_network.functionapp.name

  address_prefixes = ["10.0.0.0/25"]
  delegation {
    name = "appservice"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "functionapp" {
  source = "../../"

  name                = "${local.resource_prefix}-fa"
  location            = local.location
  resource_group_name = azurerm_resource_group.functionapp.name
  tags                = local.tags

  plan = {
    create = false
    id     = azurerm_service_plan.functionapp.id
  }

  subnet_id = azurerm_subnet.functionapp.id

  site_config = {
    container_registry_use_managed_identity = true
  }

  cors = {
    allowed_origins = ["http://www.example.com"]
  }

  functions_extension_version = "~3"
  application_stack = {
    docker_registry  = "mcr.microsoft.com"
    docker_image     = "azure-functions/dotnet"
    docker_image_tag = "3.0-appservice-quickstart"
  }

  app_settings = {
    DOCKER_ENABLE_CI = true
  }
}
