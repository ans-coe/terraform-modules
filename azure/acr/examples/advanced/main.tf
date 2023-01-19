provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

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

  address_space = ["10.126.0.0/24"]
}

resource "azurerm_subnet" "example" {
  name                 = "acr"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes  = ["10.126.0.0/25"]
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "${var.resource_prefix}-msi"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags
}

module "example" {
  source = "../../"

  name                = lower(replace("${var.resource_prefix}acr", "/[-_]/", ""))
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  sku = "Premium"

  enable_export_policy  = true
  enable_anonymous_pull = false
  enable_data_endpoint  = true

  enable_quarantine_policy = true
  enable_zone_redundancy   = true
  enable_trust_policy      = false # Disabled to enable encryption.
  enable_retention_policy  = true

  allowed_subnet_ids = [azurerm_subnet.example.id]

  georeplications = [{
    location = "northeurope"
  }]

  identity_ids = [azurerm_user_assigned_identity.example.id]

  webhooks = [{
    name    = "example"
    uri     = "https://www.example.com"
    actions = ["push"]
    enabled = false
  }]

  agent_pools = [{
    name      = "default"
    subnet_id = azurerm_subnet.example.id
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
