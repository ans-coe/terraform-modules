provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "application-gateway"
    example = "advanced"
    usage   = "demo"
  }
  resource_prefix = "agw-adv-demo-uks-03"
}

resource "azurerm_resource_group" "agw" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "agw" {
  name                = "vnet-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.agw.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "agw" {
  name                 = "snet-agw-default"
  resource_group_name  = azurerm_resource_group.agw.name
  virtual_network_name = azurerm_virtual_network.agw.name

  address_prefixes = ["10.0.0.0/27"]
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm-default"
  resource_group_name  = azurerm_resource_group.agw.name
  virtual_network_name = azurerm_virtual_network.agw.name

  address_prefixes = ["10.0.0.32/27"]
}

data "template_cloudinit_config" "agw" {
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

resource "azurerm_linux_virtual_machine_scale_set" "agw" {
  name                = "vmss-nginx-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.agw.name
  tags                = local.tags

  admin_username                  = "vmadmin"
  admin_password                  = "P4$$w0rd!"
  disable_password_authentication = false
  user_data                       = data.template_cloudinit_config.agw.rendered

  network_interface {
    name    = "primary"
    primary = true
    ip_configuration {
      name      = "primary"
      primary   = true
      subnet_id = azurerm_subnet.vm.id
      application_gateway_backend_address_pool_ids = [
        module.agw.backend_address_pools["default"],
        module.agw.backend_address_pools["example"]
      ]
    }
  }

  instances = 2
  sku       = "Standard_B1s"
  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {}
}

module "agw" {
  source = "../../"

  name                = "agw-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.agw.name
  tags                = local.tags

  sku = {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  subnet_id                  = azurerm_subnet.agw.id
  enable_private_frontend    = true
  private_frontend_ip        = cidrhost(one(azurerm_subnet.agw.address_prefixes), 10)
  private_frontend_subnet_id = azurerm_subnet.agw.id

  custom_frontend_ports = {
    "HttpAlt" = 8080
  }

  backend_address_pools = {
    "example" = {},
    "empty"   = {}
  }

  basic_backends = {
    # curl -Lkv --resolve '*':8080:${AGW_IP} http://example-basic-backend:8080/
    # curl -Lkv --resolve '*':443:${AGW_IP} https://example-basic-backend/
    "example-basic-backend" = {
      hostname                = "example-basic-backend"
      http_frontend_port_name = "HttpAlt"
      upgrade_connection      = true

      address_pool_name = "example"
      probe = {
        body         = "Welcome"
        status_codes = ["200"]
      }
    }
    # curl -Lkv --resolve '*':8080:${AGW_IP} http://example-basic-backend-noupgrade:8080/
    # curl -Lkv --resolve '*':443:${AGW_IP} https://example-basic-backend-noupgrade/
    "example-basic-backend-noupgrade" = {
      hostname                = "example-basic-backend-noupgrade"
      http_frontend_port_name = "HttpAlt"
      upgrade_connection      = false
      probe = {
        minimum_servers = 1
      }
    }
    # curl -Lkv --resolve '*':8080:${AGW_PRIVATE_IP} http://example-basic-backend-private:8080/
    # curl -Lkv --resolve '*':443:${AGW_PRIVATE_IP} https://example-basic-backend-private/
    "example-basic-backend-private" = {
      hostname         = "example-basic-backend-private"
      private_frontend = true
      probe            = { enabled = false }
    }
  }

  redirect_backends = {
    # curl -Lkv --resolve '*':80:${AGW_IP} http://example-redirect-backend/
    # curl -Lkv --resolve '*':443:${AGW_IP} https://example-redirect-backend/
    "example-redirect-backend" = {
      hostname = "example-redirect-backend"
      url      = "https://www.google.com"
    }
  }
}
