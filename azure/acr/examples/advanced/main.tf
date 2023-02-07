provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "acr"
    example = "advanced"
    usage   = "demo"
  }
  resource_prefix = "tfmex-adv-acr"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "acr" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "acr" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.acr.name
  tags                = local.tags

  address_space = ["10.126.0.0/24"]
}

resource "azurerm_subnet" "acr" {
  name                 = "acr"
  resource_group_name  = azurerm_resource_group.acr.name
  virtual_network_name = azurerm_virtual_network.acr.name

  address_prefixes  = ["10.126.0.0/25"]
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_user_assigned_identity" "acr" {
  name                = "${local.resource_prefix}-msi"
  location            = local.location
  resource_group_name = azurerm_resource_group.acr.name
  tags                = local.tags
}

module "acr" {
  source = "../../"

  name                = lower(replace("${local.resource_prefix}acr", "/[-_]/", ""))
  location            = local.location
  resource_group_name = azurerm_resource_group.acr.name
  tags                = local.tags

  sku = "Premium"

  enable_export_policy  = true
  enable_anonymous_pull = false
  enable_data_endpoint  = true

  enable_quarantine_policy = true
  enable_zone_redundancy   = true
  enable_trust_policy      = false # Disabled to enable encryption.
  enable_retention_policy  = true

  allowed_subnet_ids = [azurerm_subnet.acr.id]

  georeplications = [{
    location = "ukwest"
  }]

  identity_ids = [azurerm_user_assigned_identity.acr.id]

  webhooks = [{
    name    = "example"
    uri     = "https://www.example.com"
    actions = ["push"]
    enabled = false
  }]

  agent_pools = [{
    name      = "default"
    subnet_id = azurerm_subnet.acr.id
  }]

  scope_maps = [{
    name = "example"
    actions = [
      "repositories/example/content/read",
      "repositories/example/content/write"
    ]
  }]

  pull_object_ids = [data.azurerm_client_config.current.object_id]
  push_object_ids = [data.azurerm_client_config.current.object_id]
}
