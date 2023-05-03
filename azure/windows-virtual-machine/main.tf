resource "azurerm_public_ip" "main" {
  count = var.public_ip_enabled ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  enable_ip_forwarding = var.ip_forwarding
  dns_servers          = var.dns_servers

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = var.ip_address != null ? var.ip_address : null
    public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.main[0].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  count = var.network_security_group_enabled ? 1 : 0

  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_marketplace_agreement" "main" {
  for_each = var.accept_terms ? [0] : []

  publisher = var.source_image_reference.publisher
  offer     = var.source_image_reference.offer
  plan      = var.source_image_reference.plan
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  computer_name  = var.computer_name == null ? var.name : var.computer_name
  admin_username = var.username
  admin_password = var.password

  availability_set_id   = var.availability_set_id
  size                  = var.size
  network_interface_ids = [azurerm_network_interface.main.id]
  boot_diagnostics {}

  patch_assessment_mode = var.patch_assessment_mode

  os_disk {
    name                 = "${var.name}-osdisk"
    disk_size_gb         = var.os_disk_size_gb
    storage_account_type = var.os_disk_storage_account_type
    caching              = var.os_disk_caching
  }

  source_image_id = var.source_image_id
  license_type    = var.license_type
  dynamic "plan" {
    for_each = var.source_image_plan_required ? [local.source_image_reference] : []
    iterator = r

    content {
      name      = r.value["sku"]
      publisher = r.value["publisher"]
      product   = r.value["offer"]
    }
  }
  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [local.source_image_reference]
    iterator = r

    content {
      publisher = r.value["publisher"]
      offer     = r.value["offer"]
      sku       = r.value["sku"]
      version   = r.value["version"]
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

resource "azurerm_virtual_machine_extension" "main_azmonitor" {
  count = var.enable_azure_monitor ? 1 : 0

  name               = "AzureMonitorWindowsAgent"
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  tags               = var.tags

  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "main_azdependencyagent" {
  count = var.enable_azure_monitor ? 1 : 0

  name               = "DependencyAgentWindows"
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  tags               = var.tags

  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  settings = jsonencode({ enableAMA = "true" })
}

resource "azurerm_virtual_machine_extension" "main_aznetworkwatcheragent" {
  count = var.enable_network_watcher ? 1 : 0

  name               = "NetworkWatcherAgentWindows"
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  tags               = var.tags

  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "main_aadlogin" {
  count = var.enable_aad_login ? 1 : 0

  name               = "AADLoginForWindows"
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  tags               = var.tags

  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = false
}

resource "azurerm_virtual_machine_extension" "main_azpolicy" {
  count = var.enable_azure_policy ? 1 : 0

  name               = "AzurePolicyforWindows"
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  tags               = var.tags

  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_monitor_data_collection_rule_association" "main" {
  count = var.data_collection_enabled ? 1 : 0

  name                    = "${azurerm_windows_virtual_machine.main.name}-default"
  target_resource_id      = azurerm_windows_virtual_machine.main.id
  data_collection_rule_id = var.data_collection_rule_id

  description = "Allocate to ${azurerm_windows_virtual_machine.main.name}."

  depends_on = [azurerm_virtual_machine_extension.main_azmonitor]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  count = var.autoshutdown != null ? 1 : 0

  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  location           = var.location
  tags               = var.tags

  daily_recurrence_time = var.autoshutdown["time"]
  timezone              = var.autoshutdown["timezone"]
  notification_settings {
    enabled = var.autoshutdown["email"] != null
    email   = var.autoshutdown["email"]
  }
}
