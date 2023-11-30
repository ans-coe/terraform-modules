resource "azurerm_virtual_machine_extension" "main_aznetworkwatcheragent" {
  count = var.enable_network_watcher ? 1 : 0

  name               = "NetworkWatcherAgent"
  virtual_machine_id = local.virtual_machine.id
  tags               = var.tags

  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = var.os_type == "Windows" ? "NetworkWatcherAgentWindows" : "NetworkWatcherAgentLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "main_azpolicy" {
  count = var.enable_azure_policy ? 1 : 0

  name               = "AzurePolicy"
  virtual_machine_id = local.virtual_machine.id
  tags               = var.tags

  publisher                  = "Microsoft.GuestConfiguration"
  type                       = var.os_type == "Windows" ? "ConfigurationforWindows" : "ConfigurationforLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "main_azmonitor" {
  count = var.enable_azure_monitor ? 1 : 0

  name               = "AzureMonitorAgent"
  virtual_machine_id = local.virtual_machine.id
  tags               = var.tags

  publisher                  = "Microsoft.Azure.Monitor"
  type                       = var.os_type == "Windows" ? "AzureMonitorWindowsAgent" : "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "main_azdependencyagent" {
  count = var.enable_azure_monitor && var.enable_dependency_agent ? 1 : 0

  name               = "DependencyAgent"
  virtual_machine_id = local.virtual_machine.id
  tags               = var.tags

  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = var.os_type == "Windows" ? "DependencyAgentWindows" : "DependencyAgentLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  settings = jsonencode({ enableAMA = "true" })
}

resource "azurerm_monitor_data_collection_rule_association" "main" {
  count = var.enable_data_collection && var.enable_azure_monitor ? 1 : 0

  name                    = "${local.virtual_machine.name}-default"
  target_resource_id      = local.virtual_machine.id
  data_collection_rule_id = var.data_collection_rule_id

  description = "Allocate to ${local.virtual_machine.name}."

  depends_on = [azurerm_virtual_machine_extension.main_azmonitor]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  count = var.autoshutdown != null ? 1 : 0

  virtual_machine_id = local.virtual_machine.id
  location           = var.location
  tags               = var.tags

  daily_recurrence_time = var.autoshutdown["time"]
  timezone              = var.autoshutdown["timezone"]
  notification_settings {
    enabled = var.autoshutdown["email"] != null
    email   = var.autoshutdown["email"]
  }
}

resource "azurerm_virtual_machine_extension" "keyvault" {
  count = var.keyvault_extension_config != null ? 1 : 0

  name                 = "KeyVaultForWindows"
  virtual_machine_id   = local.virtual_machine.id
  publisher            = "Microsoft.Azure.KeyVault"
  type                 = var.os_type == "Windows" ? "KeyVaultForWindows" : "KeyVaultForLinux"
  type_handler_version = "3.0"
  auto_upgrade_minor_version = "true"

  settings = jsonencode({
    secretsManagementSettings = {
      pollingIntervalInS = "3600"
      linkOnRenewal = true
      observedCertificates = [
        {
          "url": "https://${var.keyvault_extension_config.vault_name}.vault.azure.net/secrets/${var.keyvault_extension_config.cert_name}"
          "certificateStoreName": "MY"
          "certificateStoreLocation": "LocalMachine"
        }
      ]
    }
  })
}

