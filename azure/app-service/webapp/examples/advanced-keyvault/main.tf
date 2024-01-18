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
    example    = "advanced-keyvault"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-adv-kv-aswa"
}

resource "azurerm_resource_group" "webapp" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_service_plan" "webapp" {
  name                = "${local.resource_prefix}-asp"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  sku_name = "S1"

  os_type = "Windows"
}

resource "azurerm_virtual_network" "webapp" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.webapp.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "webapp" {
  name                 = "web"
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

  os_type = "Windows"

  plan = {
    create = false
    id     = azurerm_service_plan.webapp.id
  }

  subnet_id = azurerm_subnet.webapp.id

  site_config = {
    health_check_path = "/"
  }

  cors = {
    allowed_origins = ["http://www.example.com"]
  }

  application_stack = {
    docker_image_name   = "azure-app-service/samples/aspnethelloworld:latest"
    docker_registry_url = "https://mcr.microsoft.com"
  }

  app_settings = {
    MESSAGE = "Hello"
  }

  cert_options = { // by specifying cert options, we are saying we want to use TLS on the Web App
    key_vault = {  // by specifying key_vault, we are telling the Web App that we don't want to use a managed cert, we could also specify a PFX blob.
      certificate_name      = "example-cert"
      key_vault_custom_name = "ans-example-keyvault" // this needs to be globally unique
    }
  }

  // Note: To run this example sucessfully, set this domain to a domain where you can set the asuid (validation token) TXT DNS record relevant to your Azure subscription
  // see here: https://learn.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain?tabs=root%2Cazurecli#2-create-the-dns-records
  // a quick way to get the validation token is to run the Terraform Apply. The apply will fail and will say:
  // "A TXT record pointing from asuid.test.example.com to XXXXXXXXXXXXXXX was not found".
  // This is the validation token.
  custom_domain = "test.example.com"

  identity_options = {
    umid_custom_name = "umid-example-test" // this is optional
  }

  logs = {
    level                   = "Verbose"
    detailed_error_messages = true
    failed_request_tracing  = true
    retention_in_days       = 7
    retention_in_mb         = 50
  }

  virtual_application = [
    {
      virtual_path  = "/"
      physical_path = "site\\wwwroot"
    },
    {
      virtual_path  = "/some_other_app"
      physical_path = "site\\wwwroot2"
    }
  ]
}
