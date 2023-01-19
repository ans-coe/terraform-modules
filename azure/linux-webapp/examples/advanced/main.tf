provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "logs" {
  name                = lower(replace("${var.resource_prefix}lsa", "/[-_]/", ""))
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
  account_kind    = "BlobStorage"
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.resource_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "example" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = ["10.0.0.0/25"]
  delegation {
    name = "appservice"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "example" {
  source = "../../"

  name                = "${var.resource_prefix}-wa"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  plan = {
    name           = "${var.resource_prefix}-sp"
    sku_name       = "S1"
    zone_balancing = false
  }

  subnet_id = azurerm_subnet.example.id

  site_config = {
    container_registry_use_managed_identity = true
    health_check_path                       = "/health"
  }

  application_stack = {
    docker_image     = "containous/whoami"
    docker_image_tag = "v1.5.0"
  }

  app_settings = {
    DOCKER_ENABLE_CI           = true
    DOCKER_REGISTRY_SERVER_URL = "https://index.docker.io/v1"
  }

  log_level = "Warning"
  log_config = {
    detailed_error_messages = false
    failed_request_tracing  = false
    retention_in_days       = 7
    storage_account_name    = azurerm_storage_account.logs.name
    storage_account_rg      = azurerm_storage_account.logs.resource_group_name
  }

  depends_on = [azurerm_storage_account.logs]
}
