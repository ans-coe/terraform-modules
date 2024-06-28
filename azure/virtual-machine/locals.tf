locals {
  is_windows = var.os_type == "Windows"
  default_source_image_reference = {
    publisher = local.is_windows ? "MicrosoftWindowsServer" : "Canonical"
    offer     = local.is_windows ? "WindowsServer" : "0001-com-ubuntu-server-focal"
    sku       = local.is_windows ? "2019-datacenter-gensecond" : "20_04-lts-gen2"
    version   = "latest"
  }
  source_image_reference = var.source_image_reference == null ? local.default_source_image_reference : var.source_image_reference

  virtual_machine = local.is_windows ? one(azurerm_windows_virtual_machine.main[*]) : one(azurerm_linux_virtual_machine.main[*])
}
