terraform {
  required_version = ">= 1.8.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

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
    module     = "virtual-machine"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "vm-bas-demo-uks-01"
}

variable "password" {
  description = "VM Password."
  type        = string
  sensitive   = true
}

resource "azurerm_resource_group" "vm" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vm" {
  name                = "vnet-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = local.location
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.vm.name

  address_prefixes = azurerm_virtual_network.vm.address_space
}

module "vm" {
  source = "../../"

  name                = "vm-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  os_type = "Windows"

  computer_name = "vm"
  password      = var.password

  subnet_id = azurerm_subnet.vm.id
  size      = "Standard_B2s_v2"

  enable_vm_diagnostics            = true
  diagnostics_storage_account_name = azurerm_storage_account.diag.name
}

resource "azurerm_storage_account" "diag" {
  name                     = replace("st${module.vm.name}${random_integer.sa_name.result}", "/[_-]/", "")
  resource_group_name      = azurerm_resource_group.vm.name
  location                 = azurerm_resource_group.vm.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "random_integer" "sa_name" {
  min = 100
  max = 999
}