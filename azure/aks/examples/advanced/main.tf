provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module  = "aks"
    example = "adv"
    usage   = "demo"
  }
  resource_prefix = "tfmex-adv-aks"
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

resource "azurerm_resource_group" "aks" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_container_registry" "aks" {
  name                = lower(replace("${local.resource_prefix}acr", "/[-_]/", ""))
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags

  sku = "Basic"
}

resource "azurerm_virtual_network" "aks" {
  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-default"
  resource_group_name  = azurerm_virtual_network.aks.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes  = ["10.0.0.0/20"]
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${local.resource_prefix}-msi"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "aks_nodepool" {
  name                = "${local.resource_prefix}-nodepool-msi"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_nodepool_identity" {
  description                      = "Assign the AKS identity Contributor rights to the Nodepool identity."
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true

  role_definition_name = "Contributor"
  scope                = azurerm_user_assigned_identity.aks_nodepool.id
}

module "aks" {
  source = "../../"

  name                = "${local.resource_prefix}-aks"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags

  authorized_ip_ranges       = ["${data.http.my_ip.response_body}/32"]
  aad_admin_group_object_ids = []

  # cluster_identity and kubelet_identity
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
    { day = "Sunday" }
  ]

  registry_ids = [azurerm_container_registry.aks.id]

  depends_on = [azurerm_role_assignment.aks_nodepool_identity]
}

provider "kubernetes" {
  host                   = module.aks.host
  cluster_ca_certificate = module.aks.ca_certificate
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
}

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    cluster_ca_certificate = module.aks.ca_certificate
    client_certificate     = module.aks.client_certificate
    client_key             = module.aks.client_key
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.0.18"

  create_namespace = true
  namespace        = "ingress-nginx"

  values = [
    file("${path.module}/files/helm/values/ingress-nginx.yaml")
  ]
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress_nginx.namespace
  }
}

output "ingress_ip" {
  description = "IP address of the ingress."
  value       = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
}
