provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module     = "app-service-webapp"
    example    = "advanced-linux"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-adv-lin-aswa"
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

  os_type = "Linux"

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
    health_check_path = "/health"
  }

  cors = {
    allowed_origins = ["http://www.example.com"]
  }

  application_stack = {
    docker_image_name = "containous/whoami:v1.5.0"
  }

  app_settings = {
    DOCKER_ENABLE_CI           = true
    DOCKER_REGISTRY_SERVER_URL = "https://index.docker.io/v1"
  }

  logs = {
    level                   = "Verbose"
    detailed_error_messages = true
    failed_request_tracing  = true
    retention_in_days       = 7
    retention_in_mb         = 50
  }
  autoscaling = {
    capacity = {
      default = 2
      minimum = 2
      maximum = 9
    }
    cpu_greater_than = 40
    cpu_less_than = 20
  }
}
