locals {
  default_source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  source_image_reference = var.source_image_reference == null ? local.default_source_image_reference : var.source_image_reference
}
