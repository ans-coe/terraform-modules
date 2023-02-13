provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "linux-webapp"
    example = "advanced"
    usage   = "demo"
  }
  resource_prefix = "tfmex-adv-lwa"
}

resource "azurerm_resource_group" "webapp" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_service_plan" "webapp" {
  name                = "${local.resource_prefix}-sp"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  sku_name = "S1"

  os_type = "Linux"
}

resource "azurerm_storage_account" "webapp" {
  name                = lower(replace("${local.resource_prefix}lsa", "/[-_]/", ""))
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
  account_kind    = "BlobStorage"
}

resource "azurerm_virtual_network" "webapp" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "webapp" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.webapp.name
  virtual_network_name = azurerm_virtual_network.webapp.name

  address_prefixes = ["10.0.0.0/25"]
  delegation {
    name = "appservice"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "webapp" {
  source = "../../"

  name                = "${local.resource_prefix}-wa"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  plan = {
    create = false
    id     = azurerm_service_plan.webapp.id
  }

  subnet_id = azurerm_subnet.webapp.id

  site_config = {
    container_registry_use_managed_identity = true
    health_check_path                       = "/health"
  }

  cors = {
    allowed_origins = ["http://www.example.com"]
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
    storage_account_name    = azurerm_storage_account.webapp.name
    storage_account_rg      = azurerm_storage_account.webapp.resource_group_name
  }

  depends_on = [
    # included to prevent the data source for this querying too early
    azurerm_storage_account.webapp
  ]
}
