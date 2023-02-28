locals {
  default_source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
  source_image_reference = var.source_image_reference == null ? local.default_source_image_reference : var.source_image_reference
}
