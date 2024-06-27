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
    module     = "virtual-machine"
    example    = "multi-disk"
    usage      = "demo"
    owner      = "Dee Vops"
    department = "CoE"
  }
  resource_prefix = "vm-md-demo-uks-03"
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

resource "azurerm_managed_disk" "vm" {
  count = 2

  name                = "disk${count.index}-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = local.location
  tags                = local.tags

  disk_size_gb         = 64
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
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

  enable_encryption_at_host = true

  disk_attachments = {
    "datadisk_1" = {
      id  = azurerm_managed_disk.vm[0].id
      lun = 1
    }
    "datadisk_2" = {
      id  = azurerm_managed_disk.vm[1].id
      lun = 2
    }
  }
}
