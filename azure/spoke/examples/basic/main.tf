terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.86"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module     = "spoke-vnet"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_infix = "tfmex-basic-spoke"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_infix}"
  location = local.location
  tags     = local.tags
}

module "spoke" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = "vnet-${local.resource_infix}"

  default_route_ip = "10.10.0.1"

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-default = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }

  create_network_watcher = false
}