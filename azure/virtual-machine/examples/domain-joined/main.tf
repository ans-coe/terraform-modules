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
    example = "domain-joined"
    usage   = "demo"
  }
  resource_prefix = "vm-dj-demo-uks-03"
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
  dns_servers   = ["10.0.0.10", "10.0.0.11"]
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

  os_type       = "Windows"
  computer_name = "vm"
  password      = var.password
  subnet_id     = azurerm_subnet.vm.id
  size          = "Standard_B2s"
}

resource "azurerm_virtual_machine_extension" "join_domain" {
  name               = "JsonADDomainExtension"
  virtual_machine_id = azurerm_virtual_network.vm.id
  tags               = local.tags

  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = jsonencode({
    Name    = "example.com"
    OUPath  = ""
    User    = "DomainJoiner@example.com"
    Restart = true
    Options = 3
  })

  protected_settings = jsonencode({ Password = "P4s5w0rd!" })
}
