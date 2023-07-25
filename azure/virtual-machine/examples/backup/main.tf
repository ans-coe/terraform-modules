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

variable "password" {
  description = "VM Password."
  type        = string
  sensitive   = true
}

locals {
  location = "uksouth"
  tags = {
    module  = "virtual-machine"
    example = "backup"
    usage   = "demo"
  }
  resource_prefix = "vm-bak-demo-uks-03"
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

resource "azurerm_recovery_services_vault" "vm" {
  name                = "vm-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = local.location
  tags                = local.tags

  sku               = "Standard"
  storage_mode_type = "LocallyRedundant"
}

data "azurerm_backup_policy_vm" "vm" {
  name                = "DefaultPolicy"
  resource_group_name = azurerm_resource_group.vm.name
  recovery_vault_name = azurerm_recovery_services_vault.vm.name
}

module "vm" {
  source = "../../"

  name                = "vm-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  computer_name = "vm"
  password      = var.password
  subnet_id     = azurerm_subnet.vm.id
  size          = "Standard_B2s"

  backup_config = {
    backup_policy_id = azurerm_backup_policy_vm.vm.id
  }
}
