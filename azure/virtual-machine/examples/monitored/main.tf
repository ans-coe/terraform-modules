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
    example = "monitored"
    usage   = "demo"
  }
  resource_prefix = "vm-mon-demo-uks-03"
}

resource "azurerm_resource_group" "vm" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vm" {
  name                = "vnet-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.vm.name

  address_prefixes = azurerm_virtual_network.vm.address_space
}

resource "azurerm_log_analytics_workspace" "vm" {
  name                = "log-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  retention_in_days = 30
  daily_quota_gb    = 1
}

resource "azurerm_monitor_data_collection_rule" "vm" {
  name                = "dcr-dflt-win-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  kind        = "Windows"
  description = "A default data collection rule for ${local.resource_prefix} windows VMs."

  destinations {
    log_analytics {
      name                  = "LogAnalytics"
      workspace_resource_id = azurerm_log_analytics_workspace.vm.id
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["LogAnalytics"]
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["LogAnalytics"]
  }

  data_flow {
    streams      = ["Microsoft-ServiceMap"]
    destinations = ["LogAnalytics"]
  }

  data_sources {
    performance_counter {
      name                          = "AllCounters"
      streams                       = ["Microsoft-InsightsMetrics"]
      counter_specifiers            = ["*"]
      sampling_frequency_in_seconds = 60
    }
    windows_event_log {
      name    = "AllEventlog"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]",
        "Security!*[System[(band(Keywords,13510798882111488))]]",
        "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]",
      ]
    }
    extension {
      name           = "ServiceMap"
      extension_name = "DependencyAgent"
      streams        = ["Microsoft-ServiceMap"]
    }
  }
}

module "vm" {
  source = "../../"

  name                = "vm-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = local.tags

  os_type       = "Windows"
  computer_name = "vm"
  password      = "P4s5w0rd!"

  subnet_id        = azurerm_subnet.vm.id
  enable_public_ip = true

  size = "Standard_B2s"

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
  }

  enable_azure_monitor    = true
  enable_data_collection  = true
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm.id
}
