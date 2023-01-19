provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "http" "my_ip" {
  url = "https://api.ipify.org"

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Status code from ${self.url} should return 200."
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.resource_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-default"
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = ["10.0.0.0/20"]
}

module "aks" {
  source = "../../"

  name                = "${var.resource_prefix}-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  create_acr       = true
  acr_enable_admin = true
  acr_sku          = "Basic"

  api_server_authorized_ranges = ["${data.http.my_ip.response_body}/32"]
  aad_admin_group_object_ids   = var.admin_object_ids
  disable_local_account        = false

  # cluster_identity and kubelet_identity variable
  # supports directly passing in identity resource
  cluster_identity = azurerm_user_assigned_identity.aks
  kubelet_identity = azurerm_user_assigned_identity.aks_nodepool

  node_count     = 2
  node_count_max = 3

  use_azure_cni  = true
  node_subnet_id = azurerm_subnet.aks.id
  network_policy = "azure"
  service_cidr   = "10.1.0.0/16"

  node_config = {
    os_sku            = "Ubuntu"
    kubelet_disk_type = "OS"
  }

  auto_scaler_profile = {
    balance_similar_node_groups      = true
    expander                         = "least-waste"
    scale_down_utilization_threshold = 0.3
  }

  use_log_analytics               = true
  enable_azure_policy             = true
  enable_http_application_routing = false
  enable_open_service_mesh        = true

  automatic_channel_upgrade = "stable"
  allowed_maintenance_windows = [
    {
      day   = "Saturday"
      hours = [22, 23, 0]
    },
    {
      day = "Sunday"
    }
  ]

  depends_on = [azurerm_role_assignment.aks_nodepool_identity]
}
