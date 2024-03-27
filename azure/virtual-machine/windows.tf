resource "azurerm_windows_virtual_machine" "main" {
  count = local.is_windows ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  computer_name  = var.computer_name == null ? var.name : var.computer_name
  admin_username = var.username
  admin_password = var.password

  availability_set_id        = var.availability_set_id
  zone                       = var.zone
  size                       = var.size
  network_interface_ids      = [azurerm_network_interface.main.id]
  encryption_at_host_enabled = var.enable_encryption_at_host

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }

  license_type          = var.license_type
  patch_assessment_mode = var.patch_assessment_mode
  patch_mode            = var.patch_mode
  hotpatching_enabled   = var.hotpatching_enabled

  os_disk {
    name                 = var.os_disk["name"] == null ? "osdisk-${var.name}" : var.os_disk["name"]
    disk_size_gb         = var.os_disk["size_gb"]
    storage_account_type = var.os_disk["storage_account_type"]
    caching              = var.os_disk["caching"]
  }

  source_image_id = var.source_image_id
  dynamic "plan" {
    for_each = var.source_image_plan_required ? [local.source_image_reference] : []
    content {
      name      = plan.value["sku"]
      publisher = plan.value["publisher"]
      product   = plan.value["offer"]
    }
  }
  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [local.source_image_reference]
    content {
      publisher = source_image_reference.value["publisher"]
      offer     = source_image_reference.value["offer"]
      sku       = source_image_reference.value["sku"]
      version   = source_image_reference.value["version"]
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      admin_username, admin_password
    ]
  }
}
