provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "linux-virtual-machine"
    example = "adv"
    usage   = "demo"
  }
  resource_prefix = "tfmex-adv-lvm"
}

resource "tls_private_key" "vm" {
  algorithm = "RSA"
}

data "template_cloudinit_config" "vm" {
  gzip          = false
  base64_encode = true

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
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vm" {
  name                = "${local.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.vm.name
  location            = local.location
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "vm" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.vm.name

  address_prefixes = azurerm_virtual_network.vm.address_space
}

resource "azurerm_network_security_group" "vm" {
  name                = "${local.resource_prefix}-nsg"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags
}

resource "azurerm_availability_set" "vm" {
  name                = "${local.resource_prefix}-vm-as"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  platform_fault_domain_count = 2
}

module "vm" {
  count  = 2
  source = "../../"

  name                = "${local.resource_prefix}-vm${count.index}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  computer_name = "vm${count.index}"
  public_key    = tls_private_key.vm.public_key_openssh
  user_data_b64 = data.template_cloudinit_config.vm.rendered

  subnet_id                      = azurerm_subnet.vm.id
  ip_address                     = cidrhost(azurerm_subnet.vm.address_prefixes[0], 10 + count.index)
  public_ip_enabled              = false
  network_security_group_enabled = true
  network_security_group_id      = azurerm_network_security_group.vm.id

  availability_set_id = azurerm_availability_set.vm.id
  size                = "Standard_B2s"
  os_disk_caching     = "ReadOnly"

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
  }

  autoshutdown = {}
}
