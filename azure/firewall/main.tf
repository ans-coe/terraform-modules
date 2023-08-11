#############
# Network
#############

resource "azurerm_public_ip" "main" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_subnet" "main" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_address_prefixes
}

#############
# Firewall
#############

resource "azurerm_firewall" "main" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  dns_servers         = var.firewall_dns_servers
  tags                = var.tags
  firewall_policy_id  = var.firewall_policy_id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.main.id
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

#############
# Monitoring
#############

# resource "azurerm_monitor_diagnostic_setting" "firewall-pip-diag" {
#   name                       = "${var.firewall_name}-pip-diag"
#   target_resource_id         = azurerm_public_ip.main.id
#   storage_account_id         = var.log_storage_account_name
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = var.firewall_pip_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#         days    = 0
#       }
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#       days    = 0
#     }
#   }

#   lifecycle {
#     ignore_changes = [log, metric]
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "firewall-diag" {
#   name                       = "${var.firewall_name}-diag"
#   target_resource_id         = azurerm_firewall.main.id
#   storage_account_id         = var.log_storage_account_name
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = var.firewall_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#         days    = 0
#       }
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#       days    = 0
#     }
#   }

#   lifecycle {
#     ignore_changes = [log, metric]
#   }
# }