terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

provider "azurerm" {
  features {}
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

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-default = {
      prefix           = "10.0.1.0/24"
      default_route_ip = "192.168.0.1"
    }
  }
}