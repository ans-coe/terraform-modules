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
    module  = "virtual-machine"
    example = "advanced"
    usage   = "demo"
  }
  resource_prefix = "vm-adv-demo-uks-03"
}

resource "tls_private_key" "vm" {
  algorithm = "RSA"
}

data "template_cloudinit_config" "vm" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloudconfig.web.yml"
    content_type = "text/cloud-config"
    content      = <<EOF
#cloud-config
package_update: true
package_upgrade: true
packages:
  - nginx
EOF
  }
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

resource "azurerm_lb" "vm" {
  name                = "lb-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  frontend_ip_configuration {
    name                          = "private"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vm.id
  }
}

resource "azurerm_lb_backend_address_pool" "vm" {
  name            = "vm-${local.resource_prefix}"
  loadbalancer_id = azurerm_lb.vm.id
}

resource "azurerm_network_security_group" "vm" {
  name                = "nsg-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags
}

resource "azurerm_availability_set" "vm" {
  name                = "avail-vm-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  platform_fault_domain_count = 2
}

module "vm" {
  count  = 2
  source = "../../"

  name                = format("vm%02d-%s", count.index + 1, local.resource_prefix)
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  os_type       = "Linux"
  computer_name = format("vm%02d", count.index + 1)
  public_key    = tls_private_key.vm.public_key_openssh
  user_data     = data.template_cloudinit_config.vm.rendered

  subnet_id                     = azurerm_subnet.vm.id
  ip_address                    = cidrhost(azurerm_subnet.vm.address_prefixes[0], 10 + count.index + 1)
  enable_public_ip              = false
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.vm.id]
  enable_network_security_group = true
  network_security_group_id     = azurerm_network_security_group.vm.id

  availability_set_id = azurerm_availability_set.vm.id
  size                = "Standard_B2s"
  os_disk = {
    caching = "ReadOnly"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
  }

  autoshutdown = {}
}
